class Order < ApplicationRecord
  include AASM
  include Notifiable
  include ManageCoin

  PROCESSING_RATE_TIER = 0.97
  paginates_per 30 # paginate

  IPAY88_MERCHANT_KEY     = Rails.application.secrets.ipay_merchant_key
  IPAY88_MERCHANT_CODE    = Rails.application.secrets.ipay_merchant_code
  IPAY88_REG_COMPANY_NAME = Rails.application.secrets.ipay_merchant_company

  IPAY88_PAYMENT_METHODS = [
    ['Master / Visa', 'Master / Visa'],
    ['Maybank2u', 'Maybank2u'],
    ['Alliance Online', 'Alliance Online'],
    ['AmBank Online', 'AmBank Online'],
    ['RHB Online', 'RHB Online'],
    ['Hong Leong Online', 'Hong Leong Online'],
    ['CIMB Clicks', 'CIMB Clicks'],
    ['PayPal', 'PayPal']
  ]

  aasm :column => :status do
    state :pending, initial: true
    state :paid
    state :failed

    event :set_paid do
      transitions from: [:pending], to: :paid
    end
    event :set_failed do
      transitions from: [:pending], to: :failed
    end
    event :set_pending do
      transitions from: [:paid, :failed], to: :pending
    end
  end

  belongs_to :user
  belongs_to :orderable, polymorphic: true

  scope :order_desc, -> { order('created_at desc') }
  scope :today,      -> { where("DATE(created_at) = ?", Date.today) }
  scope :month,      -> (month, year) { where("MONTH(created_at) = ? AND YEAR(created_at) = ?", month, year) }
  scope :year,       -> (year) { where("YEAR(created_at) = ?", year) }

  def full_id
    "PS#{id}"
  end

  def strict_change_status(new_status)
    order = Order.pending.find_by(id: self.id)
    if order.present?
      case new_status.to_s.downcase
      when 'pending', '0'
        order.set_pending!
      when 'paid', '1'
        order.set_paid!
      when 'failed', '2'
        order.set_failed!
      end

      return order.status
    else
      return nil
    end
  end

  def ipay88_request_code
    combine_key = "#{Order::IPAY88_MERCHANT_KEY}#{Order::IPAY88_MERCHANT_CODE}#{self.full_id}#{self.amount.to_i}00MYR"
    Digest::SHA1.base64digest(combine_key)
  end

  def ipay88_response_code(paymentID)
    combine_key = "#{Order::IPAY88_MERCHANT_KEY}#{Order::IPAY88_MERCHANT_CODE}#{paymentID}#{self.full_id}#{self.amount.to_i}00MYR1"
    Digest::SHA1.base64digest(combine_key)
  end

  def manual_approve!
    package = self.orderable
    if self.pending? && package.class.name.eql?("CoinPackage")
      self.net_amount = self.amount * Order::PROCESSING_RATE_TIER
      self.strict_change_status(:paid)
      if self.save
        set_coin(user)
        incoming_coin(package.coin, "Manual approve Top up!", {coinable_type: user.class.name, coinable_id: user.id})
      end
    end

    return self.status
  end

  def ipay88_post_url
    url = 'https://www.mobile88.com/epayment/entry.asp'
  end

  def ipay88_payment_id
    self.payment_id = ''
    case payment_method
    when 'Master / Visa'
      self.payment_id = '2'
    when 'Maybank2u'
      self.payment_id = '6'
    when 'Alliance Online'
      self.payment_id = '8'
    when 'AmBank Online'
      self.payment_id = '10'
    when 'RHB Online'
      self.payment_id = '14'
    when 'Hong Leong Online'
      self.payment_id = '15'
    when 'CIMB Clicks'
      self.payment_id = '20'
    when 'PayPal'
      self.payment_id = '48'
    end

    return self.payment_id
  end

  def ipay88_payment_method(payment_id)
    self.payment_method = ''
    case payment_id
    when '2'
      self.payment_method = 'Master / Visa'
    when '6'
      self.payment_method = 'Maybank2u'
    when '8'
      self.payment_method = 'Alliance Online'
    when '10'
      self.payment_method = 'AmBank Online'
    when '14'
      self.payment_method = 'RHB Online'
    when '15'
      self.payment_method = 'Hong Leong Online'
    when '20'
      self.payment_method = 'CIMB Clicks'
    when '48'
      self.payment_method = 'PayPal'
    end

    return self.payment_method
  end

  # def self.list_orders(year, month, today, employee)
  #   Need to change based on rajin belajar app flow, because no model employee on this app
  #   @orders = nil

  #   if today.present?
  #     @orders = if employee.present?
  #       Order.today.created_by_sales(employee)
  #     else
  #       Order.today
  #     end
  #   elsif year.present? && month.present?
  #     @orders = if employee.present?
  #       Order.paid.month(month, year).created_by_sales(employee)
  #     else
  #       Order.paid.month(month, year)
  #     end
  #   else
  #     @orders = if employee.present?
  #       Order.all.created_by_sales(employee)
  #     else
  #       Order.all
  #     end
  #   end

  #   total_count = @orders.count
  #   total_revenue = @orders.paid.sum(:amount)
  #   total_profit = @orders.paid.sum(:net_amount)

  #   @orders.instance_exec do
  #     @total_count = total_count
  #     @total_revenue = total_revenue
  #     @total_profit = total_profit

  #     def total_revenue
  #       @total_revenue
  #     end

  #     def total_profit
  #       @total_profit
  #     end

  #     def total_count
  #       @total_count
  #     end
  #   end

  #   return @orders
  # end

end
