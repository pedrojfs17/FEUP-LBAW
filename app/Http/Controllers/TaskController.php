<?php

namespace App\Http\Controllers;

use App\Models\Project;
use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function list(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('list', $project);
    $tasks = $project->tasks()->orderBy('id')->get();
    return response()->json($tasks);
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\JsonResponse
   */
  public function create(Request $request, $id)
  {
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

    return response()->json($task);
  }

  /**
   * Display the specified resource.
   *
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\JsonResponse
   */
  public function show(Request $request, $id, $task)
  {
    $this->authorize('show', Project::find($id));
    $taskObj = Task::find($task);
    return response()->json($taskObj);
  }

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\JsonResponse
   */
  public function update(Request $request, $id, $task)
  {
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

    return response()->json($taskObj);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\JsonResponse
   */
  public function delete(Request $request, $id, $task)
  {
    $this->authorize('delete', Project::find($id));
    $taskObj = Task::find($task);
    $taskObj->delete();
    return response()->json($taskObj);
  }

  public function tag(Request $request, $id, $task)
  {
    $this->authorize('tag', Project::find($id));
    Task::find($task)->tags()->attach($request->input('tag'));
  }

  public function subtask(Request $request, $id, $task)
  {
    $this->authorize('subtask', Project::find($id));
    Task::find($task)->subtasks()->attach($request->input('subtask'));
  }

  public function waiting_on(Request $request, $id, $task)
  {
    $this->authorize('waiting_on', Project::find($id));
    Task::find($task)->waitingOn()->attach($request->input('task'));
  }

  public function assignment(Request $request, $id, $task)
  {
    $this->authorize('assignment', Project::find($id));
    Task::find($task)->assignees()->attach($request->input('member'));
  }

  public function comment(Request $request, $id, $task)
  {
    $this->authorize('comment', Project::find($id));
    Task::find($task)->comments()->attach($request->input('comment'));
  }
}
