<?php

use App\Http\Controllers\SeatController;
use Illuminate\Support\Facades\Route;

Route::get('/sessions/{session}/seats', [SeatController::class, 'index']);
