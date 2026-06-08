export type Status = 'pending' | 'completed';
export type FilterType = 'all' | 'pending' | 'completed';

export interface Todo {
  id: string;
  title: string;
  description?: string;
  status: Status;
  created_at: number;
}

export class TodoStore {
  private items = new Map<string, Todo>();
  private nextId = 1;

  create(title: string, description?: string): Todo {
    if (!title.trim()) {
      throw new Error('Tiêu đề không được để trống');
    }
    const todo: Todo = {
      id: String(this.nextId++),
      title: title.trim(),
      description: description?.trim(),
      status: 'pending',
      created_at: Date.now(),
    };
    this.items.set(todo.id, todo);
    return todo;
  }

  toggleStatus(id: string): Todo {
    const todo = this.items.get(id);
    if (!todo) throw new Error(`Todo ${id} not found`);
    todo.status = todo.status === 'pending' ? 'completed' : 'pending';
    return todo;
  }

  delete(id: string): void {
    if (!this.items.has(id)) throw new Error(`Todo ${id} not found`);
    this.items.delete(id);
  }

  list(filter: FilterType = 'all'): Todo[] {
    const all = Array.from(this.items.values())
      .sort((a, b) => b.created_at - a.created_at);
    if (filter === 'all') return all;
    return all.filter(t => t.status === filter);
  }

  count(filter: FilterType): number {
    return this.list(filter).length;
  }
}

export const store = new TodoStore();
