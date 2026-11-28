<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id('product_id');
            $table->foreignId('location_id')->constrained('merchant_locations', 'location_id')->restrictOnDelete()->cascadeOnUpdate();
            $table->foreignId('category_id')->constrained('categories', 'category_id')->restrictOnDelete()->cascadeOnUpdate();
            $table->string('product_name', 150);
            $table->text('description')->nullable();
            $table->string('photo_url', 255)->nullable();
            $table->decimal('normal_price', 12, 2);
            $table->decimal('discount_price', 12, 2);
            $table->integer('stock')->default(0);
            $table->dateTime('pickup_deadline');
            $table->string('status', 20)->default('aktif');
            $table->timestamps();

            $table->index(['status', 'pickup_deadline'], 'idx_products_status_deadline');
        });

        if (DB::getDriverName() !== 'sqlite') {
            DB::statement('ALTER TABLE products ADD CONSTRAINT chk_products_normal_price CHECK (normal_price > 0)');
            DB::statement('ALTER TABLE products ADD CONSTRAINT chk_products_discount CHECK (discount_price >= 0 AND discount_price <= normal_price)');
            DB::statement('ALTER TABLE products ADD CONSTRAINT chk_products_stock CHECK (stock >= 0)');
            DB::statement("ALTER TABLE products ADD CONSTRAINT chk_products_status CHECK (status IN ('aktif','nonaktif'))");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
