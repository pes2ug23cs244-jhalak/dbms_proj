import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector
from datetime import datetime

# ------------------ DB CONFIG ------------------
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'jkna0165',
    'database': 'dbms_project'
}

def get_connection():
    return mysql.connector.connect(**DB_CONFIG)

# ------------------ HELPER FUNCTIONS ------------------
def fetch_all(table):
    try:
        conn = get_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute(f"SELECT * FROM {table}")
        rows = cur.fetchall()
    except Exception as e:
        messagebox.showerror("DB Error", f"Error fetching {table}:\n{e}")
        rows = []
    finally:
        try:
            cur.close()
            conn.close()
        except:
            pass
    return rows


def execute_query(query, params=()):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute(query, params)
        conn.commit()
        return True
    except mysql.connector.Error as e:
        if e.errno == 1452:  # Foreign key constraint fails
            messagebox.showerror(
                "Foreign Key Error",
                "Foreign key value not found! Please enter a valid related record."
            )
        else:
            messagebox.showerror("DB Error", f"Error:\n{e}")
        return False
    finally:
        try:
            cur.close()
            conn.close()
        except:
            pass

# ------------------ CUSTOM FUNCTION CALL ------------------
def show_total_sold_artworks():
    """Call the MySQL function total_sold_artworks() and show result in popup."""
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT total_sold_artworks();")
        result = cur.fetchone()
        total = result[0] if result else 0
        messagebox.showinfo("Total Sold Artworks", f"Total artworks sold: {total}")
    except Exception as e:
        messagebox.showerror("Error", f"Could not retrieve total sold artworks:\n{e}")
    finally:
        try:
            cur.close()
            conn.close()
        except:
            pass

# ------------------ CRUD FRAME CLASS ------------------
class TableFrame(tk.Frame):
    def __init__(self, master, table_name, columns, pk_column, *args, **kwargs):
        super().__init__(master, *args, **kwargs)
        self.table_name = table_name
        self.columns = columns
        self.pk_column = pk_column
        self.selected_id = None

        tk.Label(self, text=table_name, font=("Segoe UI", 12, "bold")).pack(anchor="w")

        form_frame = tk.Frame(self)
        form_frame.pack(fill="x", pady=5)

        self.vars = {}
        for i, col in enumerate(columns):
            tk.Label(form_frame, text=col).grid(row=i, column=0, sticky="w", padx=2, pady=2)
            var = tk.StringVar()
            tk.Entry(form_frame, textvariable=var).grid(row=i, column=1, sticky="ew", padx=2, pady=2)
            self.vars[col] = var
        form_frame.columnconfigure(1, weight=1)

        btn_frame = tk.Frame(self)
        btn_frame.pack(pady=4)
        tk.Button(btn_frame, text="Add", command=self.add_row).grid(row=0, column=0, padx=2)
        tk.Button(btn_frame, text="Update", command=self.update_row).grid(row=0, column=1, padx=2)
        tk.Button(btn_frame, text="Delete", command=self.delete_row).grid(row=0, column=2, padx=2)
        tk.Button(btn_frame, text="Clear", command=self.clear_form).grid(row=0, column=3, padx=2)

        # Treeview
        tree_frame = tk.Frame(self)
        tree_frame.pack(fill="both", expand=True)
        self.tree = ttk.Treeview(tree_frame, columns=columns, show="headings", height=8)
        for col in columns:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=100, anchor="w")
        vsb = ttk.Scrollbar(tree_frame, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscroll=vsb.set)
        vsb.pack(side="right", fill="y")
        self.tree.pack(fill="both", expand=True)
        self.tree.bind("<<TreeviewSelect>>", self.on_tree_select)

        self.load_rows()

    def load_rows(self):
        rows = fetch_all(self.table_name)
        for i in self.tree.get_children():
            self.tree.delete(i)
        for r in rows:
            vals = tuple(r[col] for col in self.columns)
            self.tree.insert("", "end", values=vals)

    def on_tree_select(self, event):
        sel = self.tree.selection()
        if not sel:
            return
        vals = self.tree.item(sel[0], "values")
        for i, col in enumerate(self.columns):
            self.vars[col].set(vals[i])
        self.selected_id = self.vars[self.pk_column].get()

    def clear_form(self):
        for col in self.columns:
            self.vars[col].set("")
        self.selected_id = None

    def add_row(self):
        cols = [c for c in self.columns if c != self.pk_column]
        vals = [self.vars[c].get() or None for c in cols]
        placeholders = ", ".join(["%s"] * len(vals))
        query = f"INSERT INTO {self.table_name} ({', '.join(cols)}) VALUES ({placeholders})"
        if execute_query(query, tuple(vals)):
            messagebox.showinfo("Success", f"Row added to {self.table_name}")
            self.clear_form()
            self.load_rows()

    def update_row(self):
        if not self.selected_id:
            messagebox.showwarning("Select Row", "Select a row first")
            return
        cols = [c for c in self.columns if c != self.pk_column]
        vals = [self.vars[c].get() or None for c in cols]
        assignments = ", ".join([f"{c}=%s" for c in cols])
        query = f"UPDATE {self.table_name} SET {assignments} WHERE {self.pk_column}=%s"
        if execute_query(query, tuple(vals + [self.selected_id])):
            messagebox.showinfo("Success", f"Row updated in {self.table_name}")
            self.clear_form()
            self.load_rows()

    def delete_row(self):
        if not self.selected_id:
            messagebox.showwarning("Select Row", "Select a row first")
            return
        if messagebox.askyesno("Confirm", "Delete selected row?"):
            query = f"DELETE FROM {self.table_name} WHERE {self.pk_column}=%s"
            if execute_query(query, (self.selected_id,)):
                messagebox.showinfo("Deleted", f"Row deleted from {self.table_name}")
                self.clear_form()
                self.load_rows()

# ------------------ MAIN APP ------------------
class DBMSApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("DBMS Project CRUD App")
        self.geometry("1000x850")
        canvas = tk.Canvas(self)
        scrollbar = tk.Scrollbar(self, orient="vertical", command=canvas.yview)
        self.scroll_frame = tk.Frame(canvas)
        self.scroll_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        canvas.create_window((0, 0), window=self.scroll_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Define tables, columns, PK
        tables = [
            ("artist", ["artist_ID", "first_name", "middle_name", "last_name", "country", "DOB"], "artist_ID"),
            ("artwork", ["artwork_ID", "title", "year", "type_of_artwork", "price", "status", "artist_ID", "viewing_ID", "buyer_ID"], "artwork_ID"),
            ("auction", ["auction_ID", "auction_date", "viewing_ID", "organizer_ID", "location"], "auction_ID"),
            ("bid", ["buyer_ID", "artwork_ID", "amount", "bid_date", "auction_ID"], "buyer_ID"),
            ("buyer", ["buyer_ID", "first_name", "middle_name", "last_name", "contact"], "buyer_ID"),
            ("organizer", ["organizer_ID", "first_name", "middle_name", "last_name", "contact"], "organizer_ID"),
            ("viewings", ["viewing_ID", "location", "start_date", "end_date", "organizer_ID"], "viewing_ID"),
        ]
        self.frames = []
        for tname, cols, pk in tables:
            frame = TableFrame(self.scroll_frame, tname, cols, pk, borderwidth=1, relief="solid", padx=5, pady=5)
            frame.pack(fill="x", padx=5, pady=5)
            self.frames.append(frame)

        # Add total sold artworks button
        tk.Button(self.scroll_frame, text="Show Total Sold Artworks", command=show_total_sold_artworks, bg="#0078D7", fg="white").pack(pady=10)

# ------------------ MAIN EXECUTION ------------------
if __name__ == "__main__":
    try:
        conn = get_connection()
        conn.close()
    except Exception as e:
        messagebox.showerror("DB Connection Error", f"Cannot connect to MySQL:\n{e}")
    else:
        app = DBMSApp()
        app.mainloop()
