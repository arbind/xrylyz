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
    puts "got level: #{level}"
    @question = QuizQuestion.find(id) if id
    if @question
    puts "before: #{@question.level}"
      @question.level = level
      @question.save
    puts "after: #{@question.level}"
      render :json => {level: level}
    else 
    puts "error"
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
    @questions = QuizQuestion.all
  end

  def question
    id = params[:id]
    @question = QuizQuestion.find(id) if id
  end
  def question_update
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

end