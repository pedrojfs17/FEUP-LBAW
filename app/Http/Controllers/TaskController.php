<?php

namespace App\Http\Controllers;

use App\Models\Project;
use App\Models\Tag;
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
    //$this->authorize('list', $project);

    $tags = $request->input('tag')==NULL ? NULL : explode(',',$request->input('tag'));
    $assignees =$request->input('assignees')==NULL? NULL: explode(',',$request->input('assignees'));
    $beforeDate = $request->input('due_date');

    $tasks = $project->tasks();

    $tasks = !empty($tags) ? $tasks->whereHas('tags', function ($q) use ($tags) {
      $q->whereIn('tag', $tags);
    }) : $tasks;

    $tasks = !empty($assignees) ? $tasks->whereHas('assignees', function ($q) use ($assignees) {
      $q->whereIn('client', $assignees);
    }): $tasks;

    $tasks = !empty($beforeDate) ? $tasks->whereDate('due_date',"<=",$beforeDate) : $tasks;


    $view = view('partials.projectTasks', ['tasks' => $tasks->get()])->render();
    return response()->json($view);
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\JsonResponse
   */
  public function create(Request $request, $id)
  {
    $request->validate([
      'name' => 'required|string',
      'description' => 'string',
      'due_date' => 'date|after:today',
      'task_status' => 'string',
      'parent' => 'integer'
    ]);

    $task = new Task();
    $task->project = $id;

    $this->authorize('createTask', Project::find($id));

    $task->name = $request->input('name');
    $task->description = empty($request->input('description')) ? "No description" : $request->input('description');
    $task->due_date = empty($request->input('due_date')) ? 0 : $request->input('due_date');
    $task->task_status = empty($request->input('task_status')) ? "Not Started" : $request->input('task_status');
    $task->save();

    if (!empty($request->input('parent')))
      $this->subtask($task->id, $request->input('parent'));

    $result = array();

    $result['taskCard'] = view('partials.task', ['task' => $task])->render();
    $result['taskModal'] = view('partials.taskModal', ['task' => $task])->render();

    return response()->json($result);
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

    $result = array();

    $result['taskId'] = $task;
    $result['taskCard'] = view('partials.task', ['task' => $taskObj])->render();
    $result['taskModal'] = view('partials.taskModal', ['task' => $taskObj])->render();

    return response()->json($result);
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
    $request->validate([
      'name' => 'string',
      'description' => 'string',
      'due_date' => 'date|after:today',
      'task_status' => 'string'
    ]);

    $this->authorize('updateTask', Project::find($id));

    $taskObj = Task::find($task);

    if (!empty($request->input('name')))
      $taskObj->name = $request->input('name');

    if (!empty($request->input('description')))
      $taskObj->description = $request->input('description');

    if (!empty($request->input('due_date')))
      $taskObj->due_date = $request->input('due_date');

    if (!empty($request->input('task_status')))
      $taskObj->task_status = $request->input('task_status');

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
    $this->authorize('deleteTask', Project::find($id));
    $taskObj = Task::find($task);
    $taskObj->delete();
    return response()->json($taskObj);
  }

  public function tag(Request $request, $id, $task)
  {
    //$this->authorize('tag', Project::find($id));
    $request->validate([
      'tag' => 'nullable|string',
    ]);
    Task::find($task)->tags()->detach();

    if(!empty($request->input('tag'))) {
      $tags = array_map('intval',explode(',',$request->input('tag')));
      foreach($tags as $tag) {
        Task::find($task)->tags()->attach($tag);
      }
    }

    $result = Task::find($task)->tags()->get();

    return response()->json($result);

  }

  public function subtask(Request $request, $id, $task)
  {
    //$this->authorize('subtask', Project::find($id));
    $request->validate([
      'subtask' => 'nullable|string',
    ]);

    $subTasks = Task::where('parent',$task)->get();
    foreach ($subTasks as $sub) {
      $subtaskObj = Task::find($sub->id);
      $subtaskObj->parent = null;
      $subtaskObj->save();
    }

    if(!empty($request->input('subtask'))) {
      $subtask = array_map('intval', explode(',', $request->input('subtask')));
      foreach ($subtask as $sub) {
        $subtaskObj = Task::find($sub);
        $subtaskObj->parent = $task;
        $subtaskObj->save();
      }
    }

    $result = Task::where('parent',$task)->get();

    $view = view('partials.taskButton', ['taskArray' => $result])->render();

    return response()->json($view);
  }

  public function waiting_on(Request $request, $id, $task)
  {
    //$this->authorize('waiting_on', Project::find($id));
    $request->validate([
      'waiting' => 'nullable|string',
    ]);
    Task::find($task)->waitingOn()->detach();

    if(!empty($request->input('waiting'))) {
      $waitingTasks = array_map('intval',explode(',',$request->input('waiting')));
      foreach($waitingTasks as $waiting) {
        Task::find($task)->waitingOn()->attach($waiting);
      }

    }

    $result = Task::find($task)->waitingOn()->get();

    $view = view('partials.taskButton', ['taskArray' => $result])->render();

    return response()->json($view);

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
