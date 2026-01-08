# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    # Check if the user is an AdminUser (ActiveAdmin user)
    if user.is_a?(AdminUser)
      can :manage, :all
    else
      case user.role
      when 'buyer'        
        can :read, Inventory
        cannot :manage, Inventory
      when 'seller'
        can :manage, Product
        can :manage, Inventory
      else
        # Default permissions for unrecognized roles
        can :read, :all
      end
    end
  end
end
