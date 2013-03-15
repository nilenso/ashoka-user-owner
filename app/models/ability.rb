class Ability
  include CanCan::Ability

  def initialize(user)
    can :names_for_ids, User if user
    user ||= User.new
    case user.role
    when 'admin'
      can :manage, Organization
      can :manage, User
    when 'cso_admin'
      can :manage, User, :organization_id => user.organization_id
      can :read, Organization, :id => user.organization_id
    when 'field_agent'
      can :read, User, :id => user.id
      can :read, Organization, :id => user.organization_id
    when nil
      can :create, Organization
    end
    can :me, User, :id => user.id
  end
end
