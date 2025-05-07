import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import mysql.connector
from datetime import datetime

# Admin password
admin_password = "admin"

# Function to check if the entered password is correct
def check_password():
    password = password_entry.get()
    if password == admin_password:
        add_bus()  # Call the function to add bus if password is correct
    else:
        messagebox.showerror("Error", "Incorrect password. Unable to add bus.")
        
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="koti@MYSQL974",
        database="ChennaiBusDB"
    )

def fetch_data(query, params=None):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query, params or ())
    rows = cursor.fetchall()
    cols = [desc[0] for desc in cursor.description]
    conn.close()
    return cols, rows

def populate_tree(tree, query, params=None):
    tree.delete(*tree.get_children())
    cols, rows = fetch_data(query, params)
    tree['columns'] = cols
    tree['show'] = 'headings'
    for col in cols:
        tree.heading(col, text=col)
    for row in rows:
        tree.insert("", "end", values=row)

def add_bus(bus_number, bus_type, capacity, operator):
    conn = get_connection()
    cursor = conn.cursor()
    query = "INSERT INTO buses (bus_number, bus_type, capacity, operator) VALUES (%s, %s, %s, %s)"
    cursor.execute(query, (bus_number, bus_type, capacity, operator))
    conn.commit()
    conn.close()

def delete_bus():
    def submit_deletion():
        if admin_pass.get() != "admin":
            messagebox.showerror("Access Denied", "Invalid admin password")
            return

        bus_number_val = entry_bus_number.get()
        conn = get_connection()
        cursor = conn.cursor()

        # Fetch bus info using bus_number
        cursor.execute("SELECT * FROM buses WHERE bus_number = %s", (bus_number_val,))
        old_data = cursor.fetchone()
        if not old_data:
            messagebox.showerror("Error", "Bus number not found")
            conn.close()
            return

        # Extract bus_id for logging
        bus_id = old_data[0]

        # Delete the bus
        cursor.execute("DELETE FROM buses WHERE bus_number = %s", (bus_number_val,))
        conn.commit()

        # Log the deletion
        cursor.execute("INSERT INTO edit_logs (table_name, record_id, operation, old_values, new_values) VALUES (%s, %s, %s, %s, %s)",
                       ("buses", bus_id, "delete", str(old_data), "NULL"))
        conn.commit()
        conn.close()

        messagebox.showinfo("Success", "Bus deleted successfully")
        delete_window.destroy()

    delete_window = tk.Toplevel(root)
    delete_window.title("Delete Bus")

    tk.Label(delete_window, text="Bus Number").grid(row=0, column=0)
    entry_bus_number = tk.Entry(delete_window)
    entry_bus_number.grid(row=0, column=1)

    tk.Label(delete_window, text="Admin Password").grid(row=1, column=0)
    admin_pass = tk.Entry(delete_window, show="*")
    admin_pass.grid(row=1, column=1)

    tk.Button(delete_window, text="Delete", command=submit_deletion).grid(row=2, column=0, columnspan=2)



def update_bus(bus_number, new_bus_number, new_bus_type, new_capacity, new_operator="MTC Chennai"):
    conn = get_connection()
    cursor = conn.cursor()

    # Fetch current data for logging
    cursor.execute("SELECT * FROM buses WHERE bus_number = %s", (bus_number,))
    old_data = cursor.fetchone()
    if not old_data:
        messagebox.showerror("Error", "Bus number not found")
        conn.close()
        return

    # Perform update
    cursor.execute("""
        UPDATE buses 
        SET bus_number=%s, bus_type=%s, capacity=%s, operator=%s 
        WHERE bus_number=%s
    """, (new_bus_number, new_bus_type, new_capacity, new_operator, bus_number))

    # Log update
    cursor.execute("""
        INSERT INTO edit_logs (table_name, record_id, operation, old_values, new_values) 
        VALUES (%s, %s, %s, %s, %s)
    """, (
        "buses", old_data[0], "update", str(old_data),
        str((new_bus_number, new_bus_type, new_capacity, new_operator))
    ))

    conn.commit()
    conn.close()


def show_add_bus_form():
    def submit():
        add_bus(entry_bus_number.get(), bus_type_var.get(), int(entry_capacity.get()), entry_operator.get())
        messagebox.showinfo("Success", "Bus added successfully")
        add_window.destroy()

    add_window = tk.Toplevel(root)
    add_window.title("Add Bus")

    tk.Label(add_window, text="Bus Number").grid(row=0, column=0)
    entry_bus_number = tk.Entry(add_window)
    entry_bus_number.grid(row=0, column=1)

    tk.Label(add_window, text="Bus Type").grid(row=1, column=0)
    bus_type_var = tk.StringVar()
    ttk.Combobox(add_window, textvariable=bus_type_var, values=['AC', 'Non-AC', 'Electric', 'Mini-Bus']).grid(row=1, column=1)

    tk.Label(add_window, text="Capacity").grid(row=2, column=0)
    entry_capacity = tk.Entry(add_window)
    entry_capacity.grid(row=2, column=1)

    tk.Label(add_window, text="Operator").grid(row=3, column=0)
    entry_operator = tk.Entry(add_window)
    entry_operator.insert(0, "MTC Chennai")
    entry_operator.grid(row=3, column=1)

    tk.Button(add_window, text="Add", command=submit).grid(row=4, column=0, columnspan=2)

def show_edit_bus_form():
    def submit():
        if admin_pass.get() != "admin":
            messagebox.showerror("Access Denied", "Invalid admin password")
            return
        update_bus(
            original_bus_number.get(),
            new_bus_number.get(),
            bus_type_var.get(),
            int(entry_capacity.get()),
            entry_operator.get()
        )
        messagebox.showinfo("Success", "Bus updated successfully")
        edit_window.destroy()

    edit_window = tk.Toplevel(root)
    edit_window.title("Edit Bus")

    tk.Label(edit_window, text="Original Bus Number").grid(row=0, column=0)
    original_bus_number = tk.Entry(edit_window)
    original_bus_number.grid(row=0, column=1)

    tk.Label(edit_window, text="New Bus Number").grid(row=1, column=0)
    new_bus_number = tk.Entry(edit_window)
    new_bus_number.grid(row=1, column=1)

    tk.Label(edit_window, text="Bus Type").grid(row=2, column=0)
    bus_type_var = tk.StringVar()
    ttk.Combobox(edit_window, textvariable=bus_type_var, values=['AC', 'Non-AC', 'Electric', 'Mini-Bus']).grid(row=2, column=1)

    tk.Label(edit_window, text="Capacity").grid(row=3, column=0)
    entry_capacity = tk.Entry(edit_window)
    entry_capacity.grid(row=3, column=1)

    tk.Label(edit_window, text="Operator").grid(row=4, column=0)
    entry_operator = tk.Entry(edit_window)
    entry_operator.insert(0, "MTC Chennai")
    entry_operator.grid(row=4, column=1)

    tk.Label(edit_window, text="Admin Password").grid(row=5, column=0)
    admin_pass = tk.Entry(edit_window, show="*")
    admin_pass.grid(row=5, column=1)

    tk.Button(edit_window, text="Update", command=submit).grid(row=6, column=0, columnspan=2)


def search_buses_between():
    start = entry_start.get()
    end = entry_end.get()
    query = '''
    SELECT b.bus_number, r.route_name
    FROM buses b
    JOIN schedules s ON b.bus_id = s.bus_id
    JOIN stops st ON s.stop_id = st.stop_id
    JOIN routes r ON b.bus_id = s.bus_id AND st.route_id = r.route_id
    WHERE st.stop_name = %s OR st.stop_name = %s
    GROUP BY b.bus_number, r.route_name
    HAVING COUNT(DISTINCT st.stop_name) = 2
    '''
    populate_tree(result_tree, query, (start, end))

def display_bus_info(*args):
    bus_number = selected_bus.get()
    query = '''
    SELECT r.route_name, st.stop_name, s.arrival_time, s.departure_time
    FROM buses b
    JOIN schedules s ON b.bus_id = s.bus_id
    JOIN stops st ON s.stop_id = st.stop_id
    JOIN routes r ON s.route_id = r.route_id
    WHERE b.bus_number = %s
    ORDER BY st.stop_order
    '''
    populate_tree(result_tree, query, (bus_number,))

root = tk.Tk()
root.title("Chennai Bus Management")

notebook = ttk.Notebook(root)
notebook.pack(fill='both', expand=True)

main_tab = ttk.Frame(notebook)
notebook.add(main_tab, text='Main')

bus_tab = ttk.Frame(notebook)
notebook.add(bus_tab, text='Bus Management')

# Search between stops
tk.Label(main_tab, text="From").grid(row=0, column=0)
entry_start = tk.Entry(main_tab)
entry_start.grid(row=0, column=1)

tk.Label(main_tab, text="To").grid(row=0, column=2)
entry_end = tk.Entry(main_tab)
entry_end.grid(row=0, column=3)

tk.Button(main_tab, text="Search Buses", command=search_buses_between).grid(row=0, column=4)

# Dropdown for bus info
tk.Label(main_tab, text="Bus Number").grid(row=1, column=0)
selected_bus = tk.StringVar()
bus_dropdown = ttk.Combobox(main_tab, textvariable=selected_bus)
bus_dropdown.grid(row=1, column=1)
bus_dropdown.bind("<<ComboboxSelected>>", display_bus_info)

cols, bus_rows = fetch_data("SELECT bus_number FROM buses")
bus_dropdown['values'] = [row[0] for row in bus_rows]

# Results
result_tree = ttk.Treeview(main_tab)
result_tree.grid(row=2, column=0, columnspan=5)

# Bus tab
bus_tree = ttk.Treeview(bus_tab)
bus_tree.pack(fill='both', expand=True)

btn_frame = ttk.Frame(bus_tab)
btn_frame.pack()

ttk.Button(btn_frame, text="Load Buses", command=lambda: populate_tree(bus_tree, "SELECT * FROM buses")).pack(side='left')
ttk.Button(btn_frame, text="Add Bus", command=show_add_bus_form).pack(side='left')
ttk.Button(btn_frame, text="Edit Bus", command=show_edit_bus_form).pack(side='left')
ttk.Button(btn_frame, text="Delete Bus", command=delete_bus).pack(side='left')

root.mainloop()
