<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasUuids;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'session_id',
        'seat_id',
        'user_id',
        'status',
        'reason',
        'hold_until',
    ];

    protected $casts = [
        'hold_until' => 'datetime',
    ];
}
