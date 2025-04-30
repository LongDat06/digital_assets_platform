class BulkPurchaseService
  def self.create(customer, asset_ids)
    purchases = []
    total_amount = 0
    errors = []

    ActiveRecord::Base.transaction do
      asset_ids.each do |asset_id|
        begin
          asset = Asset.find(asset_id)
          
          if customer.purchases.completed.exists?(asset_id: asset_id)
            errors << { asset_id: asset_id, errors: ['You have already purchased this asset'] }
            next
          end

          purchase = customer.purchases.build(
            asset: asset,
            amount: asset.price,
            status: 'pending'
          )

          if purchase.save
            purchases << purchase
            total_amount += purchase.amount
          else
            errors << { asset_id: asset_id, errors: purchase.errors.full_messages }
          end
        rescue ActiveRecord::RecordNotFound
          errors << { asset_id: asset_id, errors: ['Asset not found'] }
        end
      end

      raise ActiveRecord::Rollback if errors.any?
    end

    {
      success: errors.empty?,
      purchases: purchases,
      total_amount: total_amount,
      errors: errors
    }
  end
end
