class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == 'admin'
      can :manage, Organization
    elsif user.role == 'cso_admin'
      can :manage, User, :organization_id => user.organization_id
      can :read, Organization, :id => user.organization_id
    elsif user.role == 'field_agent'
      can :read, User, :id => user.id
      can :read, Organization, :id => user.organization_id
    else
      can :create, Organization
    end
  end
end
