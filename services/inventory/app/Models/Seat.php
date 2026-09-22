<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Seat extends Model
{
    protected $fillable = [
        'session_id',
        'seat_id',
        'status',
        'held_by_order',
        'hold_until',
    ];

    protected $casts = [
        'hold_until' => 'datetime',
    ];
}
