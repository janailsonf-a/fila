<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('seats', function (Blueprint $table) {
            $table->id();
            $table->string('session_id');
            $table->string('seat_id');
            $table->string('status')->default('free'); // free|held|sold
            $table->string('held_by_order')->nullable();
            $table->timestamp('hold_until')->nullable();
            $table->timestamps();

            $table->unique(['session_id', 'seat_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('seats');
    }
};
