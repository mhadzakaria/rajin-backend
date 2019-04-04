module ManageCoin
  extend ActiveSupport::Concern

  def set_coin(user)
    @user         = user
    @coin_balance = @user.coin_balance || @user.create_coin_balance(user_id: @user.id, amount: 0)
    # @coin_balance = if @user.coin_balance.blank?
    #   CoinBalance.create(user_id: @user.id, amount: 0)
    # else
    #   @user.coin_balance
    # end
  end

  def incoming_coin(amount, message, coinable={})
    coin_process(amount, message, coinable, 'Incoming')
  end

  def outgoing_name(amount, message, coinable={})
    coin_process(amount, message, coinable, 'Outgoing')
  end

  protected

  def coin_process(amount, message, coinable, process_type)
    amount                        = amount.to_f
    old_amount                    = @coin_balance.amount.to_f
    @coin_balance[:amount]        = process_type.eql?('Incoming') ? (amount + old_amount) : (old_amount - amount)
    @coin_balance[:message]       = "#{message} (#{process_type})"
    @coin_balance[:coinable_type] = coinable[:coinable_type]
    @coin_balance[:coinable_id]   = coinable[:coinable_id]
    @coin_balance.save
  end

end