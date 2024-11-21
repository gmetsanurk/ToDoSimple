# TodoSimple

**TodoSimple** is a task management application designed to provide an experience for organizing and managing your to-dos. Below is a breakdown of its features and capabilities:

## Features

### 1. Task Management
- **Task List:** Displays a list of tasks on the main screen.
- **Task Details:** Each task includes:
  - Title
  - Description(optional, you can add it separately)
  - Status Bar (completed/incomplete)
- **Task Operations:**
  - Add new tasks
  - Edit existing tasks
  - Delete tasks
- **Search Functionality:** Quickly find tasks using a search bar.
- **Long Press Gestures** Nicely share tasks, also it allows edit and delete tasks as well.

### 2. Initial Data Loading
- Loads a default list of tasks from the [DummyJSON API](https://dummyjson.com/todos) on the first launch.

### 3. Multithreading
- **Background Processing:** All operations—creating, loading, editing, deleting, and searching tasks—are handled on background threads using **Async/await** and a bit **GCD**.

### 4. CoreData Integration
- Tasks are saved locally using **CoreData**

### 5. Unit Testing
- Includes unit tests for **CoreData** components to ensure maintainability.

---
