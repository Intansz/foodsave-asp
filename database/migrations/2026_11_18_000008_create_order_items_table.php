<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('order_items', function (Blueprint $table) {
            $table->id('order_item_id');
            $table->foreignId('order_id')->constrained('orders', 'order_id')->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreignId('product_id')->constrained('products', 'product_id')->restrictOnDelete()->cascadeOnUpdate();
            $table->integer('quantity');
            $table->decimal('unit_price', 12, 2);
            $table->decimal('subtotal', 12, 2);
            $table->timestamps();

            $table->unique(['order_id', 'product_id'], 'uq_order_items_order_product');
        });

        if (DB::getDriverName() !== 'sqlite') {
            DB::statement('ALTER TABLE order_items ADD CONSTRAINT chk_order_items_quantity CHECK (quantity > 0)');
            DB::statement('ALTER TABLE order_items ADD CONSTRAINT chk_order_items_price CHECK (unit_price >= 0)');
            DB::statement('ALTER TABLE order_items ADD CONSTRAINT chk_order_items_subtotal CHECK (subtotal = quantity * unit_price)');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};
