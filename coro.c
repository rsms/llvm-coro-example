
static char g_mem_buf[2048];
static int g_mem_end = 0;

void* malloc(unsigned long size) {
  void* ptr = &g_mem_buf[g_mem_end];
  g_mem_end += size;
  return ptr;
}

void free(void* ptr) {
}
