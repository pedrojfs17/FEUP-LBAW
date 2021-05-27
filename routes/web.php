<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Static Pages
Route::view('/', 'pages.landing')->name('/');

Route::get('contacts', 'ContactsController@show')->name('contacts');
Route::post('contacts', 'ContactsController@create');

Route::get('dashboard', 'DashboardController@show')->name('dashboard');

Route::get('search', 'SearchController@show')->name('search');
Route::get('api/search', 'SearchController@search');

// Projects
Route::get('project/{project}/overview', 'ProjectController@overview')->name('project.overview');
Route::get('project/{project}/status_board', 'ProjectController@status')->name('project.status');
Route::get('project/{project}/assignments', 'ProjectController@assignments')->name('project.assignments');
//Route::get('project/{project}/statistics', 'ProjectController@statistics')->name('project.statistics');
Route::get('project/{project}/preferences', 'ProjectController@preferences')->name('project.preferences');

Route::get('api/project', 'ProjectController@list');
Route::post('api/project', 'ProjectController@create');
Route::get('api/project/{project}', 'ProjectController@show');
Route::patch('api/project/{project}', 'ProjectController@update');
Route::delete('api/project/{project}', 'ProjectController@delete');
Route::patch('api/project/{project}/{username}', 'ProjectController@editMember');
Route::delete('api/project/{project}/{username}', 'ProjectController@leave');

// Invites
Route::post('api/project/{project}/invite', 'ProjectController@invite');
Route::patch('api/project/{project}/invite/{invite}', 'ProjectController@updateInvite');

// Tags
Route::post('api/project/{project}/tag', 'TagController@create');
Route::delete('api/project/{project}/tag/{tag}', 'TagController@delete');

// Tasks
Route::get('api/project/{project}/task', 'TaskController@list');
Route::post('api/project/{project}/task', 'TaskController@create');
Route::get('api/project/{project}/task/{task}', 'TaskController@show');
Route::patch('api/project/{project}/task/{task}', 'TaskController@update');
Route::delete('api/project/{project}/task/{task}', 'TaskController@delete');

Route::patch('api/project/{project}/task/{task}/tag', 'TaskController@tag');
Route::patch('api/project/{project}/task/{task}/subtask', 'TaskController@subtask');
Route::patch('api/project/{project}/task/{task}/waiting_on', 'TaskController@waiting_on');
Route::patch('api/project/{project}/task/{task}/assignment', 'TaskController@assignment');
Route::post('api/project/{project}/task/{task}/comment', 'TaskController@comment');

Route::post('api/project/{project}/task/{task}/checklist', 'TaskController@createItem');
Route::patch('api/project/{project}/task/{task}/checklist/{checklistitem}', 'TaskController@updateItem');
Route::delete('api/project/{project}/task/{task}/checklist/{checklistitem}', 'TaskController@deleteItem');

// Social Media
//Route::get('api/account', 'SocialMediaAccountController@list');
//Route::post('api/account', 'SocialMediaAccountController@create');
//Route::get('api/account/{id}', 'SocialMediaAccountController@show');
//Route::delete('api/account/{id}', 'SocialMediaAccountController@delete');

// Authentication
Route::get('login', 'Auth\LoginController@showLoginForm')->name('login');
Route::post('login', 'Auth\LoginController@login');
Route::get('logout', 'Auth\LoginController@logout')->name('logout');
Route::get('register', 'Auth\RegisterController@showRegistrationForm')->name('register');
Route::post('register', 'Auth\RegisterController@register');

// Profile
Route::get('profile', 'ClientController@list');
Route::get('profile/{account:username}', 'ClientController@show')->name('profile');
Route::patch('profile/{account:username}', 'ClientController@update');
Route::delete('profile/{account:username}', 'ClientController@delete');
Route::get('settings', 'ClientController@showSettings')->name('settings');
Route::patch('settings', 'ClientController@updateSettings');

Route::patch('password', 'ClientController@updatePassword');
Route::get('forgot_password', 'ForgotPassword@show')->name('forgot_password');
Route::post('forgot_password', 'ForgotPassword@request');
Route::get('recover_password', 'ForgotPassword@showRecover')->name('recover_password');
Route::post('recover_password', 'ForgotPassword@recover');

Route::get('avatars/{img}', 'ImagesController@show');

// Administration
Route::get('admin/users', 'AdminController@users')->name('admin.users');
Route::get('admin/statistics', 'AdminController@statistics')->name('admin.statistics');
Route::get('admin/support', 'AdminController@support')->name('admin.support');


