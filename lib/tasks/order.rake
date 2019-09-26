namespace :user do
  desc "Requery iPay88 for pending payments"
  task(:requery_pending_payments => :environment) do
    orders = Order.pending.coin_packages

    if orders.present?
      orders.each do |unpaid_order|
        uri     = URI('http://www.mobile88.com/epayment/enquiry.asp')
        res     = Net::HTTP.post_form(uri, 'MerchantCode' => Order::IPAY88_MERCHANT_CODE,
                                           'RefNo' => unpaid_order.full_id,
                                           'Amount' => unpaid_order.amount)

        unpaid_order.topup_coin("Top up!") if res.body == "00"
      end
    else
      puts "No unpaid orders!"
    end
  end
end