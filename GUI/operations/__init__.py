# Import the operations from Task 1
from .task1 import get_task1_operations


def get_operations():
    """
    Collect all image-processing operations
    and return them to the main application.
    """

    operations = {}

    # Add Task 1 operations
    operations.update(get_task1_operations())

    # Future tasks can be added here.
    # Example:
    # from .task2 import get_task2_operations
    # operations.update(get_task2_operations())

    return operations