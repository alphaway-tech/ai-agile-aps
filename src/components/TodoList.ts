import { store, FilterType, Todo } from '../store/todo';

export interface ListResult {
  items: Todo[];
  count: number;
  filter: FilterType;
  empty: boolean;
}

export function getList(filter: FilterType = 'all'): ListResult {
  const items = store.list(filter);
  return {
    items,
    count: items.length,
    filter,
    empty: items.length === 0,
  };
}

export function toggleTodo(id: string): Todo {
  return store.toggleStatus(id);
}

export function deleteTodo(id: string): void {
  store.delete(id);
}
