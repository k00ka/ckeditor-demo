require 'test_helper'

class ActivityDefinitionsControllerTest < ActionController::TestCase
  setup do
    @activity_definition = activity_definitions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:activity_definitions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create activity_definition" do
    assert_difference('ActivityDefinition.count') do
      post :create, activity_definition: { html_blob: @activity_definition.html_blob }
    end

    assert_redirected_to activity_definition_path(assigns(:activity_definition))
  end

  test "should show activity_definition" do
    get :show, id: @activity_definition
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @activity_definition
    assert_response :success
  end

  test "should update activity_definition" do
    put :update, id: @activity_definition, activity_definition: { html_blob: @activity_definition.html_blob }
    assert_redirected_to activity_definition_path(assigns(:activity_definition))
  end

  test "should destroy activity_definition" do
    assert_difference('ActivityDefinition.count', -1) do
      delete :destroy, id: @activity_definition
    end

    assert_redirected_to activity_definitions_path
  end
end
