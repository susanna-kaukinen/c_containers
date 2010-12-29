#SConscript("main.scons", variant_dir="build", duplicate=0)

env = Environment(CC = 'gcc', CCFLAGS = '-gstabs+ -Wall')
SConscript(['vector/SConscript'])
SConscript(['tests/SConscript'])

