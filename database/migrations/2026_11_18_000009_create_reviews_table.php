<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id('review_id');
            $table->foreignId('order_id')->unique()->constrained('orders', 'order_id')->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreignId('user_id')->constrained('users', 'user_id')->restrictOnDelete()->cascadeOnUpdate();
            $table->unsignedTinyInteger('rating');
            $table->text('review_text')->nullable();
            $table->timestamps();
        });

        if (DB::getDriverName() !== 'sqlite') {
            DB::statement('ALTER TABLE reviews ADD CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5)');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
