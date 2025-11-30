# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

ProjectType.find_or_create_by!(name: "Repertoire").update(
  description: "Focuses on analyzing, learning, memorizing, and mastering complete musical pieces. Students develop interpretation,  musicality, and performance skills through the study of standard piano literature from various eras."
)

ProjectType.find_or_create_by!(name: "Standardized Test Preparation").update(
  description: "Designed to prepare students for graded music exams (such as ABRSM, RCM, or CM). Covers required repertoire, technical exercises, sight-reading, and ear training specific to the exam syllabus."
)

ProjectType.find_or_create_by!(name: "Skill Development").update(
  description: "Targeted exercises to build specific technical abilities. This includes scales, arpeggios, chords, and etudes designed to improve finger strength, dexterity, velocity, and control."
)

ProjectType.find_or_create_by!(name: "Music Theory").update(
  description: "Explores the structure and language of music. Students learn about harmony, melody, rhythm, form, and analysis to deepen their understanding of the music they play."
)

foundation = ProjectType.find_or_create_by!(name: "Foundation Development")
foundation.update(description: "The aim is to get students acclimated with piano music while building strong practice habits. The focus is on reading pitch and rhythm, eye development, and eye-finger coordination.")
