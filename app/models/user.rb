class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  belongs_to :plan
  
  # Allow us to use the token
  attr_accessor :stripe_card_token
  
  # If the Pro user passes validations (email, password, etc)
  # call up Stripe and tell Stripe to set up a subscription
  # after charging the card. Stripe responds with customer data
  # Then, store customer.id as a customer token, then we save the user
  def save_with_subscription
    if valid?
      customer = Stripe::Customer.create(description: email, plan: plan_id, source: stripe_card_token)
      self.stripe_customer_token = customer.id
      # excited!
      save!
    end
  end
end
