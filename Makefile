# ─────────────────────────────────────────────────────────────
#  CosmicRowhammer — Makefile
#  FuzzSociety / Dr. Antonio Nappa
#
#  Targets:
#    make              — build without curl (no remote reporting)
#    make WITH_CURL=1  — build with libcurl (enables --report-url)
#    make debug        — debug build with sanitizers
#    make clean        — remove build artefacts
#    make install      — install to /usr/local/bin
# ─────────────────────────────────────────────────────────────

CC       := gcc
TARGET   := cosmic_rowhammer
SRC      := cosmic_rowhammer.c

CFLAGS   := -O2 -Wall -Wextra -std=gnu11 \
            -D_GNU_SOURCE \
            -fstack-protector-strong \
            -Wformat -Wformat-security

LDFLAGS  := -lm

# ── Optional: libcurl for remote reporting ────────────────────
ifdef WITH_CURL
  CFLAGS  += -DWITH_CURL $(shell pkg-config --cflags libcurl 2>/dev/null || echo "")
  LDFLAGS += $(shell pkg-config --libs   libcurl 2>/dev/null || echo "-lcurl")
  $(info [+] Building with libcurl — remote reporting enabled)
else
  $(info [i] Building without libcurl — reports saved locally only)
  $(info     To enable remote reporting: make WITH_CURL=1)
endif

# ── Debug build ───────────────────────────────────────────────
DBGFLAGS := -O0 -g3 -fsanitize=address,undefined \
            -fno-omit-frame-pointer -DDEBUG

# ─────────────────────────────────────────────────────────────

.PHONY: all debug clean install uninstall help

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo ""
	@echo "  Built: ./$(TARGET)"
	@echo "  Run:   sudo ./$(TARGET) [--report-url <url>] [--altitude <m>]"
	@echo ""

debug: $(SRC)
	$(CC) $(CFLAGS) $(DBGFLAGS) -o $(TARGET)_debug $^ $(LDFLAGS)
	@echo "  Debug build: ./$(TARGET)_debug"

clean:
	rm -f $(TARGET) $(TARGET)_debug *.o cr_report_*.json

install: $(TARGET)
	install -m 755 $(TARGET) /usr/local/bin/$(TARGET)
	@echo "  Installed to /usr/local/bin/$(TARGET)"

uninstall:
	rm -f /usr/local/bin/$(TARGET)

help:
	@echo "CosmicRowhammer — build targets:"
	@echo "  make              Build (no remote reporting)"
	@echo "  make WITH_CURL=1  Build with libcurl"
	@echo "  make debug        Debug build + ASan/UBSan"
	@echo "  make clean        Remove artefacts"
	@echo "  make install      Install to /usr/local/bin"
	@echo ""
	@echo "Runtime options:"
	@echo "  sudo ./$(TARGET) --report-url https://data.cosmicrowhammer.io/report"
	@echo "  sudo ./$(TARGET) --altitude 2300"
	@echo "  sudo ./$(TARGET) --interval 10"
