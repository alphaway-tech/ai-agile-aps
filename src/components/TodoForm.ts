import { store } from '../store/todo';

export interface CreateResult {
  success: boolean;
  error?: string;
}

export function createTodo(title: string, description?: string): CreateResult {
  try {
    store.create(title, description);
    return { success: true };
  } catch (err) {
    return { success: false, error: (err as Error).message };
  }
}
