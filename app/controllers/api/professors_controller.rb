class Api::ProfessorsController < ActionController::API
  def lookup
    email = params[:email].to_s.strip.downcase

    if email.blank?
      render json: { error: "email is required" }, status: :unprocessable_entity
      return
    end

    user = User.includes(:journals, teacher: [ :tutorials ]).find_by("LOWER(email) = ?", email)
    teacher = user&.teacher

    unless teacher
      render json: { error: "Professor not found" }, status: :not_found
      return
    end

    projects = teacher.projects
    presentations = teacher.tutorials.includes(:skill_category)
      .with_attached_video_file
    learning_journals = user.journals.includes(:composition)

    render json: {
      email: user.email,
      professor: {
        id: teacher.id,
        name: teacher.name
      },
      projects: projects.map { |project| serialize_project(project) },
      presentations: presentations.map { |presentation| serialize_presentation(teacher, presentation) },
      learning_journals: learning_journals.map { |journal| serialize_learning_journal(teacher, journal) }
    }, status: :ok
  end

  private

    def serialize_project(project)
      {
        id: project.id,
        project_name: project.project_name,
        student_name: project.student&.name,
        project_type: project.project_type&.name,
        updated_at: project.updated_at,
        url: project_url(project)
      }
    end

    def serialize_presentation(teacher, presentation)
      {
        id: presentation.id,
        name: presentation.name,
        skill_category: presentation.skill_category&.name,
        updated_at: presentation.updated_at,
        url: professor_tutorial_url(teacher, presentation)
      }
    end

    def serialize_learning_journal(teacher, journal)
      {
        id: journal.id,
        name: journal.name,
        composition_id: journal.composition_id,
        updated_at: journal.updated_at,
        url: professor_journal_url(teacher, journal)
      }
    end
end
