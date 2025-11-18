class GroceryLists::NotifyEvents
  GROCERY_LIST_NAME_UPDATED = 'grocery_list_shared_name_updated'
  GROCERY_LIST_SHARED = 'grocery_list_shared'
  GROCERY_LIST_UNSHARED = 'grocery_list_unshared'
  GROCERY_LIST_DELETED = 'grocery_list_deleted'
  GROCERY_ITEM_ADDED = 'grocery_item_added'
  GROCERY_ITEM_REMOVED = 'grocery_item_removed'
  GROCERY_ITEM_UPDATED = 'grocery_item_updated'

  def self.name_updated(grocery_list)
    recipients = self.all_recipients_for_grocery_list(grocery_list)
    self.broadcast(recipients, GROCERY_LIST_NAME_UPDATED, { grocery_list_id: grocery_list.id, updated_name: grocery_list.name })
  end

  def self.share_list(grocery_list)
    recipients = self.all_recipients_for_grocery_list(grocery_list)
    payload = {
      grocery_list: grocery_list.as_json(
        include: [
          :items,
          { shared_users: { only: [:id, :fullname, :image_src] } }
        ]
      )
    }
    self.broadcast(recipients, GROCERY_LIST_SHARED, payload)
  end

  def self.unshare_list(grocery_list, kicked_user_id)
    recipients = self.all_recipients_for_grocery_list(grocery_list)
    self.broadcast(recipients, GROCERY_LIST_UNSHARED, { grocery_list_id: grocery_list.id, kicked_user_id: kicked_user_id })
  end

  def self.list_deleted(grocery_list)
    recipients = self.all_recipients_for_grocery_list(grocery_list)
    self.broadcast(recipients, GROCERY_LIST_DELETED, { grocery_list_id: grocery_list.id })
  end

  def self.item_added(grocery_list, added_item)
    recipients = self.all_recipients_for_grocery_list(grocery_list)
    puts "LOOK #{recipients}"
    self.broadcast(recipients, GROCERY_ITEM_ADDED, { grocery_list_id: grocery_list.id, item: added_item })
  end

  def self.item_updated(grocery_list, updated_item)
    recipients = self.all_recipients_for_grocery_list(grocery_list)
    self.broadcast(recipients, GROCERY_ITEM_UPDATED, { grocery_list_id: grocery_list.id, item: updated_item })
  end

  def self.item_removed(grocery_list, removed_item_id)
    recipients = self.all_recipients_for_grocery_list(grocery_list)
    self.broadcast(recipients, GROCERY_ITEM_REMOVED, { grocery_list_id: grocery_list.id, removed_item_id: removed_item_id })
  end

  private

  def self.all_recipients_for_grocery_list(grocery_list)
    user_ids = [grocery_list.owner_id] + grocery_list.grocery_list_shares.pluck(:user_id)
    User.where(id: user_ids.uniq)
  end

  def self.broadcast(recipients, type, payload)
    recipients.each do |user|
      begin
        NotificationsChannel.broadcast_to(user, {
          type: type,
          payload: payload
        })
      rescue => e
        Rails.logger.error("Failed to notify user #{user.id}: #{e.message}")
      end
    end
  end
end
