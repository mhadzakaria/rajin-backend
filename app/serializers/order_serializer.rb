class OrderSerializer < ApplicationSerializer
  attributes :id, :full_id, :status, :amount, :net_amount, :payment_id, :payment_gateway, :payment_method, :user_detail, :orderable, :created_at

  def user_detail(data = {})
    user = object.user
    return user_details(user)
  end

  def orderable(data = {})
    orderable = object.orderable
    case orderable.class.name
    when "CoinPackage"
      data[:id]     = orderable.id
      data[:coin]   = orderable.coin
      data[:amount] = orderable.amount
    when "Job"
      data = job_details(orderable)
    end

    return data
  end
end