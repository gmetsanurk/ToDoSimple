# TodoSimple

**TodoSimple** is a task management application designed to provide an experience for organizing and managing your to-dos. Below is a breakdown of its features and capabilities:

## Features

### 1. Task Management
- **Task List:** Displays a list of tasks on the main screen.
- **Task Details:** Each task includes:
  - Title  
  - Description (optional, you can add it separately)  
  - Status Bar (completed/incomplete)
- **Task Operations:**
  - Add new tasks
  - Edit existing tasks
  - Delete tasks
- **Search Functionality:** Quickly find tasks using a search bar.
- **Long Press Gestures:** Nicely share tasks; also allows editing and deleting tasks.

### 2. Initial Data Loading
- Loads a default list of tasks from the [DummyJSON API](https://dummyjson.com/todos) on the first launch.

### 3. Multithreading
- **Background Processing:** All operations—creating, loading, editing, deleting, and searching tasks—are handled on background threads using **async/await** and some **GCD**.

### 4. CoreData Integration
- Tasks are saved locally using **CoreData**.
- **CoreDataManager:** A custom-built library is used to manage CoreData interactions efficiently.

### 5. Architecture
- Built using the **MVP (Model-View-Presenter)** pattern combined with the **Coordinator** pattern for better separation of concerns and scalability.

### 6. Continuous Integration
- Fully configured **CI/CD pipeline** using **GitHub Actions**:
  - Automatically runs tests on push/pull requests onto master branch.
  - Ensures stability and code quality through automated checks.

### 7. Unit Testing
- Includes unit tests for **CoreData** components to ensure maintainability.

---
