json.extract! sheet_music, :id, :composition_id, :created_at, :updated_at
json.url sheet_music_url(sheet_music, format: :json)
