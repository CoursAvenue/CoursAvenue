require 'rails_helper'

describe Pro::PublicController do
  it { should_not use_before_action(:authenticate_pro_admin!) }
  it { should_not use_before_action(:authenticate_pro_super_admin!) }
end
