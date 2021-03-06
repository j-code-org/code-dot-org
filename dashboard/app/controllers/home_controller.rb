class HomeController < ApplicationController
  before_action :authenticate_user!, only: :gallery_activities

  # Don't require an authenticity token on set_locale because we post to that
  # action from publicly cached page without a valid token. The worst case impact
  # is that an attacker could change a user's language if they fooled them into
  # clicking on a link.
  skip_before_action :verify_authenticity_token, only: 'set_locale'

  def set_locale
    set_locale_cookie(params[:locale]) if params[:locale]
    if params[:i18npath]
      redirect_to "/#{params[:i18npath]}"
    elsif params[:user_return_to]
      redirect_to URI.parse(params[:user_return_to].to_s).path
    else
      redirect_to '/'
    end
  rescue URI::InvalidURIError
    redirect_to '/'
  end

  def home_insert
    if current_user
      render 'index', layout: false, formats: [:html]
    else
      render text: ''
    end
  end

  def health_check
    render text: 'healthy!'
  end

  GALLERY_PER_PAGE = 5

  def index
    if request.cookies['pm'] == 'student_homepage'
      redirect_to '/home'
    else
      redirect_to '/courses'
    end
  end

  # Show /home for teachers.  (And for students if cookie set appropriately.)
  #
  # Signed out: redirect to code.org
  # Signed in teacher or have student_homepage cookie: render this page
  # Signed in student: redirect to studio.code.org/courses

  def home
    if !current_user
      redirect_to CDO.code_org_url
    elsif current_user.teacher? || request.cookies['pm'] == 'student_homepage'
      init_homepage
      render 'home/index'
    else
      redirect_to '/courses'
    end
  end

  def gallery_activities
    if current_user
      @gallery_activities =
        current_user.gallery_activities.order(id: :desc).page(params[:page]).per(GALLERY_PER_PAGE)
    end
    render partial: 'home/gallery_content'
  end

  def certificate_link_test
    render 'certificate_link_test', formats: [:html]
  end

  # This static page combines TOS and Privacy partials all in one page
  # for easy printing.
  def terms_and_privacy
    render partial: 'home/tos_and_privacy'
  end

  # This static page contains the teacher announcements for US and non-US visitors.
  def teacher_announcements
    render template: 'api/teacher_announcement', layout: false
  end

  private

  def init_homepage
    if current_user
      @gallery_activities =
        current_user.gallery_activities.order(id: :desc).page(params[:page]).per(GALLERY_PER_PAGE)
      @force_race_interstitial = params[:forceRaceInterstitial]
      @force_school_info_interstitial = params[:forceSchoolInfoInterstitial]
      @sections = current_user.sections.map(&:summarize)
      @student_sections = current_user.sections_as_student.map(&:summarize)
      @recent_courses = current_user.recent_courses_and_scripts
      # @recent_courses are used to generate CourseCards on the homepage. Rather than a CourseCard, student's most recent assignable will be displayed with a StudentTopCourse component. See below re: student_top_course. Thus, student recent_courses should drop the first course.
      unless current_user.teacher?
        @recent_courses = current_user.recent_courses_and_scripts.drop(1)
      end

      if current_user.teacher?
        @sections = current_user.sections.map(&:summarize)
      end

      unless current_user.teacher?
        script = current_user.primary_script
        if script
          script_level = current_user.next_unpassed_progression_level(script)
        end

        if script && script_level
          @student_top_course = {
            assignableName: data_t_suffix('script.name', script[:name], 'title'),
            lessonName: script_level.stage.localized_title,
            linkToOverview: script_path(script),
            linkToLesson: script_next_path(script, 'next')
          }
        end
      end
    end
  end
end
