class Connect4Game
  include Mongoid::Document
  include Mongoid::Timestamps
  field :players, :type => Array, :default => nil
  field :board, :type => Array, :default => nil
  field :column_count, :type => Integer, :default => 7
  field :row_count, :type => Integer, :default => 6
  field :connect_to_win_count, :type => Integer, :default => 4

  field :game_is_in_progress, :type => Boolean, :default => false
  field :winner, :type => Integer, :default => 0
  field :player_to_act, :type => Integer, :default => 1

  field :player1_visitor_id, :type => String, :default=>nil
  field :player2_visitor_id, :type => String, :default=>nil

  field :_channel_id, :type => String, :default=>nil


  after_initialize :allocate_arrays, :channel_id

  def player1_visitor
    VISITORS[player1_visitor_id]
  end
  def player2_visitor
    VISITORS[player2_visitor_id]
  end

  def player1_visitor=(visitor)
      self.player1 = visitor.nickname
      self.player1_visitor_id = visitor.id.to_s
  end
  def player2_visitor=(visitor)
      self.player2 = visitor.nickname
      self.player2_visitor_id = visitor.id.to_s
  end

  def is_active?
    return (not player1_visitor.nil?) # true if player1 is a visitor
  end

  def channel_id ()
    _channel_id ||= PusherChannels.instance.channel_name_for_class_id(self.class, _id)
  end

  def game_status_for_display
    status = nil
    player_turn = nil
    msg = nil

    status = "not started"
    status = "over" if 0<winner
    status = "in progress" if game_is_in_progress
    player_turn = nil
    player_turn = player_to_act if game_is_in_progress
    msg = player(winner) + " is the winner!" if winner
    msg = "Waiting for players..." if (player1.nil? || player2.nil?)
    {
      :status => status,
      :winner => winner,
      :message => msg,
      :player_to_act => player_turn,
      :connect_to_win_count=>connect_to_win_count
    }
  end

  def game_board_for_display 
    { 
      :column_count=>column_count,
      :row_count=>row_count
    }
  end

  def player1_for_display 
    hPlayer(1)
  end
  def player2_for_display 
    hPlayer(2)
  end
  def game_players_for_display 
    [ hPlayer(1), hPlayer(2) ]
  end

  def game_pieces_for_display
    moves = []
    board.each_with_index do|col, col_num|
      col.each_with_index do |player_num, row_num|
        next if 0==player_num
        moves << hChip(player_num, col_num, row_num)
      end
    end
    moves
  end

  def hPlayer(player_num)
    {
      :player_num=>player_num,
      :name => player(player_num),
      :color => player_token(player_num),
      :is_turn_to_act => player_turn_to_act?(player_num)
    }
  end

  def hChip (player_num, col_num, row_num)
    {
      :color=>player_token(player_num),
      :col=>col_num,
      :row=>row_num
    }
  end

  def move(visitor, column_num)
    player_num = -1
    player_num = 1 if (visitor.id.to_s == player1_visitor_id)
    player_num = 2 if (visitor.id.to_s == player2_visitor_id)
    event = {}
    return nil unless 0==winner             #player(winner) has won the game
    return nil unless game_is_in_progress     #game is not in progress
    return nil unless player_to_act==player_num #Its not your turn!
    return nil if column_num < 0                #Error: invalid move
    return nil if column_num >= column_count    #Error: invalid move

    col =  self.board[column_num] 
    row_num = -1
    col.each_with_index do |token, row|
      next unless 0==token
      row_num = row
      break
    end
    return if row_num < 0                    #Error: invalid move
    return if row_num >= row_count           #Error: invalid move

    puts "droping token for player #{player_num} into colum #{column_num}"
    board[column_num][row_num] = player_num
    if player_made_winning_move?(player_num, column_num, row_num)
      self.winner=player_num 
      self.game_is_in_progress = false
    end
    #verify game_is_in_progress
    self.player_to_act = other_player(player_num)
    #last_move
    save
    event[:col] = column_num;
    event[:row] = row_num;
    event[:color] = player_token(player_num)
    event
  end

  def player1
    players[1]
  end

  def player1=(name)
    players[1] = name
  end

  def player2
    players[0]
  end

  def player2=(name)
    players[0] = name
  end

  def other_player(player_num)
    (2-player_num) + 1
  end

  def player(num)
    return player1 if 1==num
    return player2
  end
 
  def player_turn_to_act?(num)
    return false unless game_is_in_progress
    return true if player(player_to_act) == player(num)
  end

  def player_token(num)
    return "blue" if 1 == num
    return "red" if 2 == num
    nil
  end

  def for_display_as_list_item
    {
      id: _id,
      player1: player1,
      player2: player2
    }
  end

private

  def allocate_arrays
    if players.nil?
      self.players = Array.new(2)
    end
    if (board.nil? || board.empty?)
      self.board = []
      column_count.times { self.board << Array.new(row_count, 0) }
    end
  end


  def player_made_winning_move?(player_num, column_num, row_num)
    return true if move_wins_horizontally?(player_num, column_num, row_num)
    return true if move_wins_vertically?(player_num, column_num, row_num)
    return true if move_wins_diagonally?(player_num, column_num, row_num)
    return true if move_wins_diagonally_backwards?(player_num, column_num, row_num)
  end

  def move_wins_horizontally?(player_num, column_num, row_num)
    connected_token_count = 1
    connected_token_count += num_connected_tokens(player_num, column_num, row_num, -1, 0)
    connected_token_count += num_connected_tokens(player_num, column_num, row_num, 1, 0)
    connected_token_count >= connect_to_win_count
  end

  def move_wins_vertically?(player_num, column_num, row_num)
    connected_token_count = 1
    connected_token_count += num_connected_tokens(player_num, column_num, row_num, 0, -1)
    connected_token_count += num_connected_tokens(player_num, column_num, row_num, 0, 1)
    connected_token_count >= connect_to_win_count
  end

  def move_wins_diagonally?(player_num, column_num, row_num)
    connected_token_count = 1
    connected_token_count += num_connected_tokens(player_num, column_num, row_num, 1, 1)
    connected_token_count += num_connected_tokens(player_num, column_num, row_num, -1, -1)
    connected_token_count >= connect_to_win_count
  end
  def move_wins_diagonally_backwards?(player_num, column_num, row_num)
    connected_token_count = 1
    connected_token_count += num_connected_tokens(player_num, column_num, row_num, -1, 1)
    connected_token_count += num_connected_tokens(player_num, column_num, row_num,  1, -1)
    connected_token_count >= connect_to_win_count
  end

  def num_connected_tokens(player_num, column_num, row_num, delta_column, delta_row)
    links = []
    connected_tokens_count = 0
    col = column_num
    row = row_num
    while true
      col += delta_column
      row += delta_row
      break if col < 0
      break if row < 0
      break if col >= column_count
      break if row >= row_count
      break unless player_num==board[col][row]
      connected_tokens_count += 1
      links << [col, row]
    end
    connected_tokens_count
  end

end
