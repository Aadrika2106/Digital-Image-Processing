import os
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox

import numpy as np
from PIL import Image, ImageTk

# Use ttkbootstrap if available for a better-looking interface.
# Otherwise, use normal tkinter ttk.
try:
    import ttkbootstrap as ttk
    BOOTSTRAP_AVAILABLE = True
except ImportError:
    import tkinter.ttk as ttk
    BOOTSTRAP_AVAILABLE = False

from operations import get_operations


# =========================================================
# PATHS
# =========================================================

# Folder containing this app.py file
SCRIPT_DIR = Path(__file__).resolve().parent

# All processed images will be saved here
OUTPUT_DIR = SCRIPT_DIR / "Output"
OUTPUT_DIR.mkdir(exist_ok=True)


# =========================================================
# GUI SETTINGS
# =========================================================

WINDOW_WIDTH = 1150
WINDOW_HEIGHT = 720

THUMBNAIL_SIZE = 260


# =========================================================
# MAIN APPLICATION
# =========================================================

class ImageProcessingApp:

    def __init__(self):

        # -------------------------------------------------
        # Create the main window
        # -------------------------------------------------

        if BOOTSTRAP_AVAILABLE:

            self.root = ttk.Window(
                title="Image Processing Toolkit",
                themename="darkly"
            )

            self.root.geometry(
                f"{WINDOW_WIDTH}x{WINDOW_HEIGHT}"
            )

        else:

            self.root = tk.Tk()

            self.root.title(
                "Image Processing Toolkit"
            )

            self.root.geometry(
                f"{WINDOW_WIDTH}x{WINDOW_HEIGHT}"
            )

        self.root.minsize(
            1000,
            650
        )


        # -------------------------------------------------
        # Application state
        # -------------------------------------------------

        self.input_image = None
        self.input_path = None

        # Stores all processed images
        self.results = {}

        # Prevents Tkinter images from disappearing
        self.image_references = []


        # -------------------------------------------------
        # Load all image-processing operations
        # -------------------------------------------------

        self.operations = get_operations()

        if not self.operations:

            messagebox.showerror(
                "Error",
                "No image-processing operations were found."
            )

            self.root.destroy()
            return


        # -------------------------------------------------
        # Build the interface
        # -------------------------------------------------

        self.build_interface()


        # -------------------------------------------------
        # Start application
        # -------------------------------------------------

        self.root.mainloop()


    # =====================================================
    # BUILD INTERFACE
    # =====================================================

    def build_interface(self):

        # -------------------------------------------------
        # Header
        # -------------------------------------------------

        header = ttk.Frame(
            self.root
        )

        header.pack(
            fill="x",
            padx=18,
            pady=(15, 5)
        )

        title = ttk.Label(
            header,
            text="Image Processing Toolkit",
            font=("Arial", 20, "bold")
        )

        title.pack(
            side="left"
        )

        subtitle = ttk.Label(
            header,
            text="Interactive Image Processing & Analysis"
        )

        subtitle.pack(
            side="left",
            padx=15
        )


        # -------------------------------------------------
        # Controls
        # -------------------------------------------------

        controls = ttk.Frame(
            self.root
        )

        controls.pack(
            fill="x",
            padx=18,
            pady=12
        )


        # Operation label

        ttk.Label(
            controls,
            text="Operation:"
        ).pack(
            side="left"
        )


        # Operation dropdown

        self.operation_var = tk.StringVar()

        operation_names = list(
            self.operations.keys()
        )

        self.operation_var.set(
            operation_names[0]
        )

        self.operation_menu = ttk.Combobox(
            controls,
            textvariable=self.operation_var,
            values=operation_names,
            state="readonly",
            width=40
        )

        self.operation_menu.pack(
            side="left",
            padx=10
        )


        # Select image button

        self.select_button = ttk.Button(
            controls,
            text="Select Image",
            command=self.select_image
        )

        self.select_button.pack(
            side="left",
            padx=5
        )


        # Run button

        self.run_button = ttk.Button(
            controls,
            text="Run",
            command=self.run_operation,
            state="disabled"
        )

        self.run_button.pack(
            side="left",
            padx=5
        )


        # Clear button

        self.clear_button = ttk.Button(
            controls,
            text="Clear",
            command=self.clear_results
        )

        self.clear_button.pack(
            side="left",
            padx=5
        )


        # -------------------------------------------------
        # Main content area
        # -------------------------------------------------

        main = ttk.Frame(
            self.root
        )

        main.pack(
            fill="both",
            expand=True,
            padx=18,
            pady=5
        )


        # =================================================
        # INPUT PANEL
        # =================================================

        input_frame = ttk.LabelFrame(
            main,
            text="Input Image"
        )

        input_frame.pack(
            side="left",
            fill="both",
            padx=(0, 10),
            pady=5
        )

        self.input_label = ttk.Label(
            input_frame,
            text="No image selected"
        )

        self.input_label.pack(
            expand=True,
            padx=20,
            pady=20
        )


        # File name

        self.filename_label = ttk.Label(
            input_frame,
            text="",
            wraplength=280
        )

        self.filename_label.pack(
            pady=(0, 8)
        )


        # Image information

        self.info_label = ttk.Label(
            input_frame,
            text=""
        )

        self.info_label.pack(
            pady=(0, 15)
        )


        # =================================================
        # OUTPUT PANEL
        # =================================================

        output_frame = ttk.LabelFrame(
            main,
            text="Processing Results"
        )

        output_frame.pack(
            side="left",
            fill="both",
            expand=True,
            padx=(10, 0),
            pady=5
        )


        # -------------------------------------------------
        # Scrollable output area
        # -------------------------------------------------

        self.canvas = tk.Canvas(
            output_frame,
            highlightthickness=0
        )

        scrollbar = ttk.Scrollbar(
            output_frame,
            orient="vertical",
            command=self.canvas.yview
        )

        self.output_container = ttk.Frame(
            self.canvas
        )


        # Update scroll region whenever output changes

        self.output_container.bind(
            "<Configure>",
            lambda event:
            self.canvas.configure(
                scrollregion=self.canvas.bbox("all")
            )
        )


        # Put output frame inside canvas

        self.canvas.create_window(
            (0, 0),
            window=self.output_container,
            anchor="nw"
        )

        self.canvas.configure(
            yscrollcommand=scrollbar.set
        )


        self.canvas.pack(
            side="left",
            fill="both",
            expand=True
        )

        scrollbar.pack(
            side="right",
            fill="y"
        )


        # Initial message

        self.placeholder = ttk.Label(
            self.output_container,
            text="Select an image and choose an operation."
        )

        self.placeholder.pack(
            padx=30,
            pady=50
        )


        # -------------------------------------------------
        # Mouse-wheel scrolling
        # -------------------------------------------------

        self.canvas.bind_all(
            "<MouseWheel>",
            self.scroll_output
        )


        # =================================================
        # BOTTOM BAR
        # =================================================

        bottom = ttk.Frame(
            self.root
        )

        bottom.pack(
            fill="x",
            padx=18,
            pady=12
        )


        # Save button

        self.save_button = ttk.Button(
            bottom,
            text="Save All Results",
            command=self.save_all,
            state="disabled"
        )

        self.save_button.pack(
            side="left"
        )


        # Open output folder

        self.open_folder_button = ttk.Button(
            bottom,
            text="Open Output Folder",
            command=self.open_output_folder
        )

        self.open_folder_button.pack(
            side="left",
            padx=10
        )


        # Status

        self.status_label = ttk.Label(
            bottom,
            text="Ready"
        )

        self.status_label.pack(
            side="right"
        )


    # =====================================================
    # SELECT IMAGE
    # =====================================================

    def select_image(self):

        path = filedialog.askopenfilename(

            title="Select an Image",

            filetypes=[
                (
                    "Image Files",
                    "*.png *.jpg *.jpeg *.bmp *.tiff *.webp"
                ),
                (
                    "All Files",
                    "*.*"
                )
            ]
        )


        # User cancelled

        if not path:
            return


        # Try opening image

        try:

            image = Image.open(
                path
            ).convert("RGB")

        except Exception as error:

            messagebox.showerror(
                "Image Error",
                f"Could not open the selected image.\n\n{error}"
            )

            return


        # Store image

        self.input_image = image
        self.input_path = path


        # -------------------------------------------------
        # Display input thumbnail
        # -------------------------------------------------

        thumbnail = image.copy()

        thumbnail.thumbnail(
            (320, 320)
        )

        photo = ImageTk.PhotoImage(
            thumbnail
        )

        self.input_label.configure(
            image=photo,
            text=""
        )

        # Keep reference
        self.input_label.image = photo


        # -------------------------------------------------
        # Display file information
        # -------------------------------------------------

        filename = os.path.basename(
            path
        )

        width, height = image.size

        self.filename_label.configure(
            text=filename
        )

        self.info_label.configure(
            text=f"Size: {width} × {height}"
        )


        # Enable Run

        self.run_button.configure(
            state="normal"
        )


        self.status_label.configure(
            text="Image loaded successfully"
        )


    # =====================================================
    # RUN SELECTED OPERATION
    # =====================================================

    def run_operation(self):

        if self.input_image is None:

            messagebox.showwarning(
                "No Image",
                "Please select an image first."
            )

            return


        operation_name = (
            self.operation_var.get()
        )


        # Find corresponding processing function

        operation = self.operations.get(
            operation_name
        )


        if operation is None:

            messagebox.showerror(
                "Operation Error",
                "Selected operation was not found."
            )

            return


        try:

            self.status_label.configure(
                text="Processing..."
            )

            self.root.update_idletasks()


            # Convert PIL image to NumPy array

            image_array = np.array(
                self.input_image
            )


            # Run processing algorithm

            self.results = operation(
                image_array
            )


            # Display results

            self.display_results(
                self.results
            )


            # Enable saving

            self.save_button.configure(
                state="normal"
            )


            self.status_label.configure(
                text=f"Completed: {operation_name}"
            )


        except Exception as error:

            messagebox.showerror(
                "Processing Error",
                str(error)
            )

            self.status_label.configure(
                text="Processing failed"
            )


    # =====================================================
    # DISPLAY RESULTS
    # =====================================================

    def display_results(
        self,
        results
    ):

        # Remove previous results

        for widget in (
            self.output_container.winfo_children()
        ):

            widget.destroy()


        self.image_references.clear()


        # Number of columns

        columns = 2


        # Display each result

        for index, (
            name,
            image
        ) in enumerate(
            results.items()
        ):


            row = index // columns
            column = index % columns


            # Result card

            card = ttk.Frame(
                self.output_container
            )

            card.grid(
                row=row,
                column=column,
                padx=12,
                pady=12,
                sticky="n"
            )


            # Make thumbnail

            thumbnail = image.copy()

            thumbnail.thumbnail(
                (
                    THUMBNAIL_SIZE,
                    THUMBNAIL_SIZE
                )
            )


            photo = ImageTk.PhotoImage(
                thumbnail
            )


            # Keep reference

            self.image_references.append(
                photo
            )


            # Image

            image_label = ttk.Label(
                card,
                image=photo
            )

            image_label.pack()


            # Result name

            ttk.Label(
                card,
                text=name,
                wraplength=THUMBNAIL_SIZE
            ).pack(
                pady=6
            )


    # =====================================================
    # CLEAR RESULTS
    # =====================================================

    def clear_results(self):

        # Remove output images

        for widget in (
            self.output_container.winfo_children()
        ):

            widget.destroy()


        self.image_references.clear()

        self.results = {}


        # Show placeholder

        self.placeholder = ttk.Label(
            self.output_container,
            text="Select an image and choose an operation."
        )

        self.placeholder.pack(
            padx=30,
            pady=50
        )


        # Disable save button

        self.save_button.configure(
            state="disabled"
        )


        self.status_label.configure(
            text="Results cleared"
        )


    # =====================================================
    # SAVE ALL RESULTS
    # =====================================================

    def save_all(self):

        if not self.results:
            return


        # Original filename without extension

        base_name = Path(
            self.input_path
        ).stem


        saved_files = []


        for name, image in (
            self.results.items()
        ):


            # Make filename safe

            safe_name = (
                name
                .replace(" ", "_")
                .replace("/", "_")
                .replace("\\", "_")
            )


            output_path = (
                OUTPUT_DIR /
                f"{base_name}_{safe_name}.png"
            )


            # Save image

            image.save(
                output_path
            )


            saved_files.append(
                output_path.name
            )


        # Show confirmation

        messagebox.showinfo(
            "Results Saved",
            f"{len(saved_files)} result(s) saved in:\n\n"
            f"{OUTPUT_DIR}"
        )


        self.status_label.configure(
            text=f"Saved {len(saved_files)} result(s)"
        )


    # =====================================================
    # OPEN OUTPUT FOLDER
    # =====================================================

    def open_output_folder(self):

        try:

            os.startfile(
                str(OUTPUT_DIR)
            )

        except Exception as error:

            messagebox.showerror(
                "Error",
                f"Could not open output folder.\n\n{error}"
            )


    # =====================================================
    # OUTPUT SCROLLING
    # =====================================================

    def scroll_output(self, event):

        self.canvas.yview_scroll(
            int(-1 * (event.delta / 120)),
            "units"
        )


# =========================================================
# START APPLICATION
# =========================================================

if __name__ == "__main__":

    ImageProcessingApp()