<?php

namespace App\Http\Controllers;

use App\Models\Task;
use http\Env\Response;
use Illuminate\Http\Request;

use Illuminate\Support\Facades\Auth;

class TaskController extends Controller
{
  /**
   * Show the form for creating a new resource.
   *
   * @return Task
   */
  public function create(Request $request, $id)
  {
    if (!Auth::check()) return redirect('login');

    $validated = $request->validate([
      'name' => 'required|string',
      'description' => 'string',
      'due_date' => 'integer',
      'task_status' => 'string',
      'parent' => 'integer'
    ]);

    $task = new Task();

    $this->authorize('create', $task);

    $task->project = $id;
    $task->name = $validated->input('name');
    $task->description = empty($validated->input('description')) ? "No description" : $validated->input('description');
    $task->due_date = empty($validated->input('due_date')) ? 0 : $validated->input('due_date');
    $task->task_status = empty($validated->input('task_status')) ? "Not Started" : $validated->input('task_status');
    $task->save();

    if (!empty($validated->input('parent')))
      $this->subtask($task->id, $validated->input('parent'));

    return $task;
  }

  /**
   * Display the specified resource.
   *
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\Response
   */
  public function show($id)
  {
    if (!Auth::check()) return redirect('login');
    $task = Task::find($id);
    $this->authorize('show', $task);
    return Response::json($task);
  }

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\Response
   */
  public function update(Request $request, $project, $id)
  {
    if (!Auth::check()) return redirect('login');

    $validated = $request->validate([
      'name' => 'string',
      'project' => 'string',
      'due_date' => 'integer',
      'task_status' => 'string'
    ]);

    $task = Task::find($id);
    $this->authorize('update', $task);
    $task->name = empty($validated->input('name')) ? $task->name : $validated->input('name');
    $task->description = empty($validated->input('description')) ? $task->description : $validated->input('description');
    $task->due_date = empty($validated->input('due_date')) ? $task->due_date : $validated->input('due_date');
    $task->task_status = empty($validated->input('task_status')) ? $task->task_status : $validated->input('task_status');
    $task->save();
    return $task;
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\Response
   */
  public function delete(Request $request, $id)
  {
    if (!Auth::check()) return redirect('login');
    $task = Task::find($id);
    $this->authorize('delete', $task);
    $task->delete();
    return $task;
  }

  public function list()
  {
    if (!Auth::check()) return redirect('/login');
    $this->authorize('list', Task::class);
    return Response::json(Auth::user()->projects()->tasks()->orderBy('id')->get());
  }

  public function tag($task_id, $tag_id)
  {
    if (!Auth::check()) return redirect('login');
    $task = Task::find($task_id);
    $task->tags()->attach($tag_id);
  }

  public function subtask($task1_id, $task2_id)
  {
    if (!Auth::check()) return redirect('login');
    $task = Task::find($task1_id);
    $task->subtasks()->attach($task2_id);
  }

  public function waitingOn($task1_id, $task2_id)
  {
    if (!Auth::check()) return redirect('login');
    $task = Task::find($task1_id);
    $task->waitingOn()->attach($task2_id);
  }

  public function assignment($task_id, $client_id)
  {
    if (!Auth::check()) return redirect('login');
    $task = Task::find($task_id);
    $task->assignees()->attach($client_id);
  }

  public function comment($task_id, $comment_id)
  {
    if (!Auth::check()) return redirect('login');
    $task = Task::find($task_id);
    $task->comments()->attach($comment_id);
  }
}
