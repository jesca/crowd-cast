require 'test_helper'

class AdvertisementsControllerTest < ActionController::TestCase
  setup do
    @advertisement = advertisements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:advertisements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create advertisement" do
    assert_difference('Advertisement.count') do
      post :create, advertisement: { advertisement_url: @advertisement.advertisement_url, advertiser_id: @advertisement.advertiser_id, description: @advertisement.description, screen_resolution_x: @advertisement.screen_resolution_x, screen_resolution_y: @advertisement.screen_resolution_y, title: @advertisement.title }
    end

    assert_redirected_to advertisement_path(assigns(:advertisement))
  end

  test "should show advertisement" do
    get :show, id: @advertisement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @advertisement
    assert_response :success
  end

  test "should update advertisement" do
    patch :update, id: @advertisement, advertisement: { advertisement_url: @advertisement.advertisement_url, advertiser_id: @advertisement.advertiser_id, description: @advertisement.description, screen_resolution_x: @advertisement.screen_resolution_x, screen_resolution_y: @advertisement.screen_resolution_y, title: @advertisement.title }
    assert_redirected_to advertisement_path(assigns(:advertisement))
  end

  test "should destroy advertisement" do
    assert_difference('Advertisement.count', -1) do
      delete :destroy, id: @advertisement
    end

    assert_redirected_to advertisements_path
  end
end
