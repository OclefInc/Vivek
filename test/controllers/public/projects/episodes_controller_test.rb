require "test_helper"

class Public::Projects::EpisodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = assignments(:one)
    @episode = lessons(:one)
  end

  test "should get index" do
    get project_episodes_path(@project)
    assert_response :success
  end

  test "should get show" do
    get project_episode_path(@project, @episode)
    assert_response :success
  end
end
