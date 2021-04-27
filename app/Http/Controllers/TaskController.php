<?php

namespace App\Http\Controllers;

use App\Models\Project;
use App\Models\Task;
use http\Env\Response;
use Illuminate\Http\Request;

use Illuminate\Support\Facades\Auth;

class TaskController extends Controller
{
  public function list(Request $request, $id)
  {
    if (!Auth::check()) return redirect('login');
    $project = Project::find($id);
    $this->authorize('list', $project);
    return Response::json($project->tasks()->orderBy('id')->get());
  }

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
    $task->project = $id;

    $this->authorize('create', Project::find($id));

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
  public function show(Request $request, $id, $task)
  {
    if (!Auth::check()) return redirect('login');
    $this->authorize('show', Project::find($id));
    return Response::json(Task::find($task));
  }

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\Response
   */
  public function update(Request $request, $id, $task)
  {
    if (!Auth::check()) return redirect('login');

    $validated = $request->validate([
      'name' => 'string',
      'project' => 'string',
      'due_date' => 'integer',
      'task_status' => 'string'
    ]);

    $this->authorize('update', Project::find($id));

    $taskObj = Task::find($task);
    $taskObj->name = empty($validated->input('name')) ? $taskObj->name : $validated->input('name');
    $taskObj->description = empty($validated->input('description')) ? $taskObj->description : $validated->input('description');
    $taskObj->due_date = empty($validated->input('due_date')) ? $taskObj->due_date : $validated->input('due_date');
    $taskObj->task_status = empty($validated->input('task_status')) ? $taskObj->task_status : $validated->input('task_status');
    $taskObj->save();

    return $taskObj;
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\Response
   */
  public function delete(Request $request, $id, $task)
  {
    if (!Auth::check()) return redirect('login');
    $this->authorize('delete', Project::find($id));
    $taskObj = Task::find($task);
    $taskObj->delete();
    return $taskObj;
  }

  public function tag(Request $request, $id, $task)
  {
    if (!Auth::check()) return redirect('login');
    $this->authorize('tag', Project::find($id));
    $taskObj = Task::find($task);
    $taskObj->tags()->attach($request->input('tag'));
  }

  public function subtask($task1_id, $task2_id)
  {
    if (!Auth::check()) return redirect('login');
    $task = Task::find($task1_id);
    $task->subtasks()->attach($task2_id);
  }

  public function waiting_on($task1_id, $task2_id)
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
