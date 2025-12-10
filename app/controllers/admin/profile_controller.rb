class Admin::ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def show
    @teacher = current_user.teacher

    if @teacher.nil?
      redirect_to teachers_path, alert: "You don't have a teacher profile yet."
    end
  end

  def edit
    @teacher = current_user.teacher

    if @teacher.nil?
      redirect_to teachers_path, alert: "You don't have a teacher profile yet."
    end
  end

  def update
    @teacher = current_user.teacher

    if @teacher.nil?
      redirect_to teachers_path, alert: "You don't have a teacher profile yet."
      return
    end

    if @teacher.update(teacher_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def teacher_params
      params.expect(teacher: [ :profile_picture, :name, :city, :bio, :avatar_crop_x, :avatar_crop_y, :avatar_crop_width, :avatar_crop_height ])
    end
end
