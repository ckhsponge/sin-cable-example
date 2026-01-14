class CreateWebsocketConnections < ActiveRecord::Migration[8.1]
  def up
    create_table :websocket_connections, id: :uuid do |t|
      t.string :connection_id, null: false

      t.timestamps
    end

    add_index :websocket_connections, :connection_id, unique: true
  end

  def down
    drop_table :websocket_connections
  end

end
