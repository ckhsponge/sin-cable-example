class CreateWebsocketSubscriptions < ActiveRecord::Migration[8.1]
  def up
    create_table :websocket_subscriptions, id: :uuid do |t|
      t.string :connection_id, null: false
      t.string :path, null: false

      t.timestamps
    end

    add_index :websocket_subscriptions, [:path, :connection_id], unique: true
    add_index :websocket_subscriptions, :connection_id
  end

  def down
    drop_table :websocket_subscriptions
  end
end
