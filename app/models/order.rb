class Order < ApplicationRecord
  include Notifiable

  PROCESSING_RATE_TIER = 0.97
  paginates_per 30 # paginate

  IPAY88_MERCHANT_KEY     = 'xxxxxxxxx'
  IPAY88_MERCHANT_CODE    = 'xxxxxxx'
  IPAY88_REG_COMPANY_NAME = 'XXXX Sdn Bhd'

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

  COIN_PACKAGES = [
    ['COINS 20', 10],
    ['COINS 50', 25],
    ['COINS 100', 50]
  ]

  enum status: [:pending, :paid, :failed]

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
    order = Order.where(id: self.id, status: Order.statuses[:pending]).first
    if order.present?
      order.send("#{new_status}!")
    else
      nil
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
    # Need to change based on rajin belajar app flow
    # if self.user.agent?
    #   agency = self.user.agent.agency
    #   sale = agency.sale_representatives.first

    #   if self.user.agent.employee.present?
    #     self.employee = self.user.agent.employee
    #   else
    #     self.employee = sale
    #   end
    # end

    # self.net_amount = self.amount * Order::PROCESSING_RATE_TIER
    # self.status = :paid

    # if self.save
    #   self.user.topup_credit(self.total_credits_awarded)
    #   self.user.update_credit_expiry(self.expiry_date)
    # end
  end

  def ipay88_post_url
    url = 'https://www.mobile88.com/epayment/entry.asp'
  end

  def ipay88_payment_id
    payment_id = ''
    case payment_method
    when 'Master / Visa'
      payment_id = '2'
    when 'Maybank2u'
      payment_id = '6'
    when 'Alliance Online'
      payment_id = '8'
    when 'AmBank Online'
      payment_id = '10'
    when 'RHB Online'
      payment_id = '14'
    when 'Hong Leong Online'
      payment_id = '15'
    when 'CIMB Clicks'
      payment_id = '20'
    when 'PayPal'
      payment_id = '48'
    end

    return payment_id
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
