class Sudo::Apps::QuizController < Sudo::SudoController

  def index

  end

  def quizes
    @quizes = Quiz.all
  end

  def quiz
    id = params[:id]
    @quiz = Quiz.find(id) if id
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