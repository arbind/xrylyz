class Sudo::Apps::QuizController < Sudo::SudoController

  def index

  end

  def quizes
    clear = params[:clear]
    unless clear.nil?
      session[:quiz_filter] = {}
    end

    db_filters = session[:quiz_filter] || {}

    filter = params[:filter]
    if filter
      if db_filters[filter].nil?
        db_filters[filter] = true 
      else
        db_filters[filter] =  !db_filters[filter]  #toggle
      end
      db_filters["is_rejected"] = false if "is_approved" == filter and true == db_filters[filter]
      db_filters["is_approved"] = false if "is_rejected" == filter and true == db_filters[filter]
    end

    session[:quiz_filter] = db_filters

    puts "filters = #{db_filters}"

    @where = {}.merge(db_filters)

    @quizes = Quiz.where(@where)

    puts "where = #{@where}"
    @html_submenu_buttons = quiz_submenu

  end

  def quiz
    id = params[:id]
    @quiz = Quiz.find(id) if id
  end

  def quiz_create
    @quiz = Quiz.create
    redirect_to sudo_apps_quiz_quiz_url(@quiz)
  end

  def quiz_update
    puts params
    id = params[:id]
    @quiz = Quiz.find(id) if id

    if @quiz
      q = params[:quiz]
      d = params[:dates]
      if d and d[:start] 
        start_at = DateTime.strptime(d[:start], "%m/%d/%Y").utc.beginning_of_day
        q['online_at'] = start_at
        q['offline_at'] = start_at + 1.day
      end
      @quiz.update_attributes(q)
      # @quiz.save
    end
    
    redirect_to sudo_apps_quiz_quiz_url(@quiz)
  end

  def quiz_delete
    id = params[:id]
    @quiz = Quiz.find(id) if id

    msg = @quiz.kind || @quiz.id.to_s
    if @quiz
      @quiz.destroy
    end

    redirect_to sudo_apps_quiz_quizes_url, :flash => {:warn => "Deleted quiz:\n#{msg}!"}
  end

  def quiz_approve
    id = params[:id]
    @quiz = Quiz.find(id) if id
    if @quiz
      @quiz.is_approved = true
      @quiz.is_rejected = false
      @quiz.save
      puts "Approving!"
    end
    render :json => {ok: true}
  end

  def quiz_unapprove
    id = params[:id]
    @quiz = Quiz.find(id) if id
    if @quiz
      @quiz.is_approved = false
      @quiz.save
      puts "Unapproving!"
    end
    render :json => {ok: true}
  end

  def quiz_reject
    id = params[:id]
    @quiz = Quiz.find(id) if id
    if @quiz
      @quiz.is_rejected = true
      @quiz.is_approved = false
      @quiz.save
      puts "Rejecting!"
    end
    render :json => {ok: true}
  end

  def quiz_unreject
    id = params[:id]
    @quiz = Quiz.find(id) if id
    if @quiz
      @quiz.is_rejected = false
      @quiz.save
      puts "un rejecting!"
    end
    render :json => {ok: true}
  end


  def quiz_add_question
    quiz_id = params[:id]
    question_id = params[:question_id]
    quiz = Quiz.find(quiz_id) if quiz_id
    quiz_question = QuizQuestion.find(question_id) if question_id
    (quiz.questions << quiz_question) if quiz_question
    quiz.save
    redirect_to sudo_apps_quiz_quiz_url(quiz)
  end


  def quiz_remove_question
    quiz_id = params[:id]
    question_id = params[:question_id]
    quiz = Quiz.find(quiz_id) if quiz_id
    quiz_question = QuizQuestion.find(question_id) if question_id
    quiz.questions.delete(quiz_question) if quiz_question
    # quiz.save
    redirect_to sudo_apps_quiz_quiz_url(quiz)
  end







  def questions
    clear = params[:clear]
    unless clear.nil?
      session[:quiz_questions_filter] = {}
      session[:quiz_questions_level] = nil
      session[:quiz_questions_unanswered] = nil
    end

    db_filters = session[:quiz_questions_filter] || {}
    db_level = session[:quiz_questions_level] || -2
    db_unanswered = session[:quiz_questions_unanswered] || 0

    filter = params[:filter]
    if filter
      if db_filters[filter].nil?
        db_filters[filter] = true 
      else
        db_filters[filter] =  !db_filters[filter]  #toggle
      end
      db_filters["is_rejected"] = false if "is_approved" == filter and true == db_filters[filter]
      db_filters["is_approved"] = false if "is_rejected" == filter and true == db_filters[filter]
    end

    level = params[:level]
    if not level.nil?
      level = level.to_i
      if level == db_level
        db_level = -2  #toggle
      else
        db_level = level
      end
    end

    unanswered = params[:unanswered]
    if not unanswered.nil?
      db_unanswered = (0==db_unanswered ? 1 : 0) # toggle
    end

    session[:quiz_questions_filter] = db_filters
    session[:quiz_questions_level] = db_level
    session[:quiz_questions_unanswered] = db_unanswered

    puts "filters = #{db_filters}"
    puts "level = #{db_level}"

    @where = {}.merge(db_filters)
    @where[:level] = db_level if db_level > -2

    @where[:correct_answer] = {'$lt' => 0} if 1==db_unanswered

    @questions = QuizQuestion.where(@where)

    if @where[:correct_answer]
      @where.delete(:correct_answer)
      @where[:unanswered] = true 
    end

    puts "where = #{@where}"
    @html_submenu_buttons = quiz_questions_submenu
  end

  def question
    id = params[:id]
    @question = QuizQuestion.find(id) if id
  end

  def question_create
    @question = QuizQuestion.create
    redirect_to sudo_apps_quiz_question_url(@question)
  end

  def question_update
    puts params
    id = params[:id]
    @question = QuizQuestion.find(id) if id

    if @question
      q = params[:question]

      @question.update_attributes(q)
      @question[1] = params[:answer1]
      @question[2] = params[:answer2]
      @question[3] = params[:answer3]
      @question[4] = params[:answer4]
      @question.save
    end
    
    redirect_to sudo_apps_quiz_question_path(@question)
  end

  def question_delete
    puts params
    id = params[:id]
    @question = QuizQuestion.find(id) if id

    msg = @question.prompt || @question.id.to_s
    # msg = truncate(msg, length: 28)
    if @question
      @question.destroy
    end

    redirect_to sudo_apps_quiz_questions_path, :flash => {:warn => "Deleted question:\n#{msg}!"}
  end

  def post_level
    id = params[:id]
    level = params[:level].to_i
    @question = QuizQuestion.find(id) if id
    if @question
      @question.level = level
      @question.save
      render :json => {level: level}
    else 
      render :json => {error: 'true'}
    end
  end

  def post_correct_answer
    id = params[:id]
    correct_answer = params[:correct_answer].to_i

    @question = QuizQuestion.find(id) if id
    if @question
      @question.correct_answer = correct_answer
      @question.save
      render :json => {correct_answer: @question.correct_answer}
    else 
      render :json => {error: 'true'}
    end
  end

  def question_approve
    id = params[:id]
    @question = QuizQuestion.find(id) if id
    if @question
      @question.is_approved = true
      @question.is_rejected = false
      @question.save
      puts "Approving!"
    end
    render :json => {ok: true}
  end

  def question_unapprove
    id = params[:id]
    @question = QuizQuestion.find(id) if id
    if @question
      @question.is_approved = false
      @question.save
      puts "Unapproving!"
    end
    render :json => {ok: true}
  end
  def question_reject
    id = params[:id]
    @question = QuizQuestion.find(id) if id
    if @question
      @question.is_rejected = true
      @question.is_approved = false
      @question.save
      puts "Rejecting!"
    end
    render :json => {ok: true}
  end

  def question_unreject
    id = params[:id]
    @question = QuizQuestion.find(id) if id
    if @question
      @question.is_rejected = false
      @question.save
      puts "un rejecting!"
    end
    render :json => {ok: true}
  end

  private

  def quiz_submenu
    [
      {name: 'all', href: sudo_apps_quiz_quizes_url(clear: "true")},
      {name: 'completed',     href: sudo_apps_quiz_quizes_url(filter: "is_complete")},
      {name: 'approved',      href: sudo_apps_quiz_quizes_url(filter: "is_approved")},
      {name: 'rejected',      href: sudo_apps_quiz_quizes_url(filter: "is_rejected")},
    ]
  end

  def quiz_questions_submenu
    [
      {name: 'all', href: sudo_apps_quiz_questions_url(clear: "true")},
      {name: 'completed',     href: sudo_apps_quiz_questions_url(filter: "is_complete")},
      {name: 'approved',      href: sudo_apps_quiz_questions_url(filter: "is_approved")},
      {name: 'rejected',      href: sudo_apps_quiz_questions_url(filter: "is_rejected")},
      {name: 'unanswered',    href: sudo_apps_quiz_questions_url(unanswered: "1")},
      {name: 'level -',       href: sudo_apps_quiz_questions_url(level: "-1")},
      {name: 'level 1',       href: sudo_apps_quiz_questions_url(level: "1")},
      {name: 'level 2',       href: sudo_apps_quiz_questions_url(level: "2")},
      {name: 'level 3',       href: sudo_apps_quiz_questions_url(level: "3")},
    ]
  end

end