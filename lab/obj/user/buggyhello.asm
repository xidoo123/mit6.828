
obj/user/buggyhello.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 a6 04 00 00       	call   80053e <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 2a 22 80 00       	push   $0x80222a
  800111:	6a 23                	push   $0x23
  800113:	68 47 22 80 00       	push   $0x802247
  800118:	e8 9a 13 00 00       	call   8014b7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 2a 22 80 00       	push   $0x80222a
  800192:	6a 23                	push   $0x23
  800194:	68 47 22 80 00       	push   $0x802247
  800199:	e8 19 13 00 00       	call   8014b7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 2a 22 80 00       	push   $0x80222a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 47 22 80 00       	push   $0x802247
  8001db:	e8 d7 12 00 00       	call   8014b7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 2a 22 80 00       	push   $0x80222a
  800216:	6a 23                	push   $0x23
  800218:	68 47 22 80 00       	push   $0x802247
  80021d:	e8 95 12 00 00       	call   8014b7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 2a 22 80 00       	push   $0x80222a
  800258:	6a 23                	push   $0x23
  80025a:	68 47 22 80 00       	push   $0x802247
  80025f:	e8 53 12 00 00       	call   8014b7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 2a 22 80 00       	push   $0x80222a
  80029a:	6a 23                	push   $0x23
  80029c:	68 47 22 80 00       	push   $0x802247
  8002a1:	e8 11 12 00 00       	call   8014b7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 2a 22 80 00       	push   $0x80222a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 47 22 80 00       	push   $0x802247
  8002e3:	e8 cf 11 00 00       	call   8014b7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 2a 22 80 00       	push   $0x80222a
  800340:	6a 23                	push   $0x23
  800342:	68 47 22 80 00       	push   $0x802247
  800347:	e8 6b 11 00 00       	call   8014b7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	05 00 00 00 30       	add    $0x30000000,%eax
  80037e:	c1 e8 0c             	shr    $0xc,%eax
}
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
  800389:	05 00 00 00 30       	add    $0x30000000,%eax
  80038e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800393:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a5:	89 c2                	mov    %eax,%edx
  8003a7:	c1 ea 16             	shr    $0x16,%edx
  8003aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b1:	f6 c2 01             	test   $0x1,%dl
  8003b4:	74 11                	je     8003c7 <fd_alloc+0x2d>
  8003b6:	89 c2                	mov    %eax,%edx
  8003b8:	c1 ea 0c             	shr    $0xc,%edx
  8003bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c2:	f6 c2 01             	test   $0x1,%dl
  8003c5:	75 09                	jne    8003d0 <fd_alloc+0x36>
			*fd_store = fd;
  8003c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ce:	eb 17                	jmp    8003e7 <fd_alloc+0x4d>
  8003d0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003da:	75 c9                	jne    8003a5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ef:	83 f8 1f             	cmp    $0x1f,%eax
  8003f2:	77 36                	ja     80042a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f4:	c1 e0 0c             	shl    $0xc,%eax
  8003f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fc:	89 c2                	mov    %eax,%edx
  8003fe:	c1 ea 16             	shr    $0x16,%edx
  800401:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800408:	f6 c2 01             	test   $0x1,%dl
  80040b:	74 24                	je     800431 <fd_lookup+0x48>
  80040d:	89 c2                	mov    %eax,%edx
  80040f:	c1 ea 0c             	shr    $0xc,%edx
  800412:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800419:	f6 c2 01             	test   $0x1,%dl
  80041c:	74 1a                	je     800438 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800421:	89 02                	mov    %eax,(%edx)
	return 0;
  800423:	b8 00 00 00 00       	mov    $0x0,%eax
  800428:	eb 13                	jmp    80043d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042f:	eb 0c                	jmp    80043d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 05                	jmp    80043d <fd_lookup+0x54>
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043d:	5d                   	pop    %ebp
  80043e:	c3                   	ret    

0080043f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800448:	ba d4 22 80 00       	mov    $0x8022d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044d:	eb 13                	jmp    800462 <dev_lookup+0x23>
  80044f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800452:	39 08                	cmp    %ecx,(%eax)
  800454:	75 0c                	jne    800462 <dev_lookup+0x23>
			*dev = devtab[i];
  800456:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800459:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	eb 2e                	jmp    800490 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800462:	8b 02                	mov    (%edx),%eax
  800464:	85 c0                	test   %eax,%eax
  800466:	75 e7                	jne    80044f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800468:	a1 08 40 80 00       	mov    0x804008,%eax
  80046d:	8b 40 48             	mov    0x48(%eax),%eax
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	51                   	push   %ecx
  800474:	50                   	push   %eax
  800475:	68 58 22 80 00       	push   $0x802258
  80047a:	e8 11 11 00 00       	call   801590 <cprintf>
	*dev = 0;
  80047f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800482:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800490:	c9                   	leave  
  800491:	c3                   	ret    

00800492 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	56                   	push   %esi
  800496:	53                   	push   %ebx
  800497:	83 ec 10             	sub    $0x10,%esp
  80049a:	8b 75 08             	mov    0x8(%ebp),%esi
  80049d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a3:	50                   	push   %eax
  8004a4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004aa:	c1 e8 0c             	shr    $0xc,%eax
  8004ad:	50                   	push   %eax
  8004ae:	e8 36 ff ff ff       	call   8003e9 <fd_lookup>
  8004b3:	83 c4 08             	add    $0x8,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 05                	js     8004bf <fd_close+0x2d>
	    || fd != fd2)
  8004ba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bd:	74 0c                	je     8004cb <fd_close+0x39>
		return (must_exist ? r : 0);
  8004bf:	84 db                	test   %bl,%bl
  8004c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c6:	0f 44 c2             	cmove  %edx,%eax
  8004c9:	eb 41                	jmp    80050c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d1:	50                   	push   %eax
  8004d2:	ff 36                	pushl  (%esi)
  8004d4:	e8 66 ff ff ff       	call   80043f <dev_lookup>
  8004d9:	89 c3                	mov    %eax,%ebx
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	78 1a                	js     8004fc <fd_close+0x6a>
		if (dev->dev_close)
  8004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	74 0b                	je     8004fc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f1:	83 ec 0c             	sub    $0xc,%esp
  8004f4:	56                   	push   %esi
  8004f5:	ff d0                	call   *%eax
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	56                   	push   %esi
  800500:	6a 00                	push   $0x0
  800502:	e8 e1 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	89 d8                	mov    %ebx,%eax
}
  80050c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050f:	5b                   	pop    %ebx
  800510:	5e                   	pop    %esi
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    

00800513 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800519:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051c:	50                   	push   %eax
  80051d:	ff 75 08             	pushl  0x8(%ebp)
  800520:	e8 c4 fe ff ff       	call   8003e9 <fd_lookup>
  800525:	83 c4 08             	add    $0x8,%esp
  800528:	85 c0                	test   %eax,%eax
  80052a:	78 10                	js     80053c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	6a 01                	push   $0x1
  800531:	ff 75 f4             	pushl  -0xc(%ebp)
  800534:	e8 59 ff ff ff       	call   800492 <fd_close>
  800539:	83 c4 10             	add    $0x10,%esp
}
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <close_all>:

void
close_all(void)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	53                   	push   %ebx
  800542:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800545:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	53                   	push   %ebx
  80054e:	e8 c0 ff ff ff       	call   800513 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800553:	83 c3 01             	add    $0x1,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	83 fb 20             	cmp    $0x20,%ebx
  80055c:	75 ec                	jne    80054a <close_all+0xc>
		close(i);
}
  80055e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	57                   	push   %edi
  800567:	56                   	push   %esi
  800568:	53                   	push   %ebx
  800569:	83 ec 2c             	sub    $0x2c,%esp
  80056c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800572:	50                   	push   %eax
  800573:	ff 75 08             	pushl  0x8(%ebp)
  800576:	e8 6e fe ff ff       	call   8003e9 <fd_lookup>
  80057b:	83 c4 08             	add    $0x8,%esp
  80057e:	85 c0                	test   %eax,%eax
  800580:	0f 88 c1 00 00 00    	js     800647 <dup+0xe4>
		return r;
	close(newfdnum);
  800586:	83 ec 0c             	sub    $0xc,%esp
  800589:	56                   	push   %esi
  80058a:	e8 84 ff ff ff       	call   800513 <close>

	newfd = INDEX2FD(newfdnum);
  80058f:	89 f3                	mov    %esi,%ebx
  800591:	c1 e3 0c             	shl    $0xc,%ebx
  800594:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80059a:	83 c4 04             	add    $0x4,%esp
  80059d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a0:	e8 de fd ff ff       	call   800383 <fd2data>
  8005a5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a7:	89 1c 24             	mov    %ebx,(%esp)
  8005aa:	e8 d4 fd ff ff       	call   800383 <fd2data>
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b5:	89 f8                	mov    %edi,%eax
  8005b7:	c1 e8 16             	shr    $0x16,%eax
  8005ba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c1:	a8 01                	test   $0x1,%al
  8005c3:	74 37                	je     8005fc <dup+0x99>
  8005c5:	89 f8                	mov    %edi,%eax
  8005c7:	c1 e8 0c             	shr    $0xc,%eax
  8005ca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d1:	f6 c2 01             	test   $0x1,%dl
  8005d4:	74 26                	je     8005fc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e5:	50                   	push   %eax
  8005e6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e9:	6a 00                	push   $0x0
  8005eb:	57                   	push   %edi
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 b3 fb ff ff       	call   8001a6 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	78 2e                	js     80062a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ff:	89 d0                	mov    %edx,%eax
  800601:	c1 e8 0c             	shr    $0xc,%eax
  800604:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	25 07 0e 00 00       	and    $0xe07,%eax
  800613:	50                   	push   %eax
  800614:	53                   	push   %ebx
  800615:	6a 00                	push   $0x0
  800617:	52                   	push   %edx
  800618:	6a 00                	push   $0x0
  80061a:	e8 87 fb ff ff       	call   8001a6 <sys_page_map>
  80061f:	89 c7                	mov    %eax,%edi
  800621:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800624:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800626:	85 ff                	test   %edi,%edi
  800628:	79 1d                	jns    800647 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 00                	push   $0x0
  800630:	e8 b3 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800635:	83 c4 08             	add    $0x8,%esp
  800638:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063b:	6a 00                	push   $0x0
  80063d:	e8 a6 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	89 f8                	mov    %edi,%eax
}
  800647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5e                   	pop    %esi
  80064c:	5f                   	pop    %edi
  80064d:	5d                   	pop    %ebp
  80064e:	c3                   	ret    

0080064f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
  800652:	53                   	push   %ebx
  800653:	83 ec 14             	sub    $0x14,%esp
  800656:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800659:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	e8 86 fd ff ff       	call   8003e9 <fd_lookup>
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	89 c2                	mov    %eax,%edx
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 6d                	js     8006d9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800672:	50                   	push   %eax
  800673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800676:	ff 30                	pushl  (%eax)
  800678:	e8 c2 fd ff ff       	call   80043f <dev_lookup>
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	85 c0                	test   %eax,%eax
  800682:	78 4c                	js     8006d0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800684:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800687:	8b 42 08             	mov    0x8(%edx),%eax
  80068a:	83 e0 03             	and    $0x3,%eax
  80068d:	83 f8 01             	cmp    $0x1,%eax
  800690:	75 21                	jne    8006b3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800692:	a1 08 40 80 00       	mov    0x804008,%eax
  800697:	8b 40 48             	mov    0x48(%eax),%eax
  80069a:	83 ec 04             	sub    $0x4,%esp
  80069d:	53                   	push   %ebx
  80069e:	50                   	push   %eax
  80069f:	68 99 22 80 00       	push   $0x802299
  8006a4:	e8 e7 0e 00 00       	call   801590 <cprintf>
		return -E_INVAL;
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b1:	eb 26                	jmp    8006d9 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b6:	8b 40 08             	mov    0x8(%eax),%eax
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	74 17                	je     8006d4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bd:	83 ec 04             	sub    $0x4,%esp
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	ff 75 0c             	pushl  0xc(%ebp)
  8006c6:	52                   	push   %edx
  8006c7:	ff d0                	call   *%eax
  8006c9:	89 c2                	mov    %eax,%edx
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb 09                	jmp    8006d9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	eb 05                	jmp    8006d9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d9:	89 d0                	mov    %edx,%eax
  8006db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 0c             	sub    $0xc,%esp
  8006e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f4:	eb 21                	jmp    800717 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f6:	83 ec 04             	sub    $0x4,%esp
  8006f9:	89 f0                	mov    %esi,%eax
  8006fb:	29 d8                	sub    %ebx,%eax
  8006fd:	50                   	push   %eax
  8006fe:	89 d8                	mov    %ebx,%eax
  800700:	03 45 0c             	add    0xc(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	57                   	push   %edi
  800705:	e8 45 ff ff ff       	call   80064f <read>
		if (m < 0)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	85 c0                	test   %eax,%eax
  80070f:	78 10                	js     800721 <readn+0x41>
			return m;
		if (m == 0)
  800711:	85 c0                	test   %eax,%eax
  800713:	74 0a                	je     80071f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800715:	01 c3                	add    %eax,%ebx
  800717:	39 f3                	cmp    %esi,%ebx
  800719:	72 db                	jb     8006f6 <readn+0x16>
  80071b:	89 d8                	mov    %ebx,%eax
  80071d:	eb 02                	jmp    800721 <readn+0x41>
  80071f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800724:	5b                   	pop    %ebx
  800725:	5e                   	pop    %esi
  800726:	5f                   	pop    %edi
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	53                   	push   %ebx
  80072d:	83 ec 14             	sub    $0x14,%esp
  800730:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800736:	50                   	push   %eax
  800737:	53                   	push   %ebx
  800738:	e8 ac fc ff ff       	call   8003e9 <fd_lookup>
  80073d:	83 c4 08             	add    $0x8,%esp
  800740:	89 c2                	mov    %eax,%edx
  800742:	85 c0                	test   %eax,%eax
  800744:	78 68                	js     8007ae <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800750:	ff 30                	pushl  (%eax)
  800752:	e8 e8 fc ff ff       	call   80043f <dev_lookup>
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	85 c0                	test   %eax,%eax
  80075c:	78 47                	js     8007a5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800761:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800765:	75 21                	jne    800788 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800767:	a1 08 40 80 00       	mov    0x804008,%eax
  80076c:	8b 40 48             	mov    0x48(%eax),%eax
  80076f:	83 ec 04             	sub    $0x4,%esp
  800772:	53                   	push   %ebx
  800773:	50                   	push   %eax
  800774:	68 b5 22 80 00       	push   $0x8022b5
  800779:	e8 12 0e 00 00       	call   801590 <cprintf>
		return -E_INVAL;
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800786:	eb 26                	jmp    8007ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800788:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078b:	8b 52 0c             	mov    0xc(%edx),%edx
  80078e:	85 d2                	test   %edx,%edx
  800790:	74 17                	je     8007a9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800792:	83 ec 04             	sub    $0x4,%esp
  800795:	ff 75 10             	pushl  0x10(%ebp)
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	50                   	push   %eax
  80079c:	ff d2                	call   *%edx
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	eb 09                	jmp    8007ae <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a5:	89 c2                	mov    %eax,%edx
  8007a7:	eb 05                	jmp    8007ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ae:	89 d0                	mov    %edx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	ff 75 08             	pushl  0x8(%ebp)
  8007c2:	e8 22 fc ff ff       	call   8003e9 <fd_lookup>
  8007c7:	83 c4 08             	add    $0x8,%esp
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 0e                	js     8007dc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	83 ec 14             	sub    $0x14,%esp
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007eb:	50                   	push   %eax
  8007ec:	53                   	push   %ebx
  8007ed:	e8 f7 fb ff ff       	call   8003e9 <fd_lookup>
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 65                	js     800860 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800801:	50                   	push   %eax
  800802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800805:	ff 30                	pushl  (%eax)
  800807:	e8 33 fc ff ff       	call   80043f <dev_lookup>
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	85 c0                	test   %eax,%eax
  800811:	78 44                	js     800857 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800813:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800816:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081a:	75 21                	jne    80083d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800821:	8b 40 48             	mov    0x48(%eax),%eax
  800824:	83 ec 04             	sub    $0x4,%esp
  800827:	53                   	push   %ebx
  800828:	50                   	push   %eax
  800829:	68 78 22 80 00       	push   $0x802278
  80082e:	e8 5d 0d 00 00       	call   801590 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083b:	eb 23                	jmp    800860 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800840:	8b 52 18             	mov    0x18(%edx),%edx
  800843:	85 d2                	test   %edx,%edx
  800845:	74 14                	je     80085b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	50                   	push   %eax
  80084e:	ff d2                	call   *%edx
  800850:	89 c2                	mov    %eax,%edx
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	eb 09                	jmp    800860 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800857:	89 c2                	mov    %eax,%edx
  800859:	eb 05                	jmp    800860 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800860:	89 d0                	mov    %edx,%eax
  800862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	83 ec 14             	sub    $0x14,%esp
  80086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800871:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	ff 75 08             	pushl  0x8(%ebp)
  800878:	e8 6c fb ff ff       	call   8003e9 <fd_lookup>
  80087d:	83 c4 08             	add    $0x8,%esp
  800880:	89 c2                	mov    %eax,%edx
  800882:	85 c0                	test   %eax,%eax
  800884:	78 58                	js     8008de <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088c:	50                   	push   %eax
  80088d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800890:	ff 30                	pushl  (%eax)
  800892:	e8 a8 fb ff ff       	call   80043f <dev_lookup>
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	85 c0                	test   %eax,%eax
  80089c:	78 37                	js     8008d5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a5:	74 32                	je     8008d9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b1:	00 00 00 
	stat->st_isdir = 0;
  8008b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008bb:	00 00 00 
	stat->st_dev = dev;
  8008be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	53                   	push   %ebx
  8008c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8008cb:	ff 50 14             	call   *0x14(%eax)
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	eb 09                	jmp    8008de <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	eb 05                	jmp    8008de <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	6a 00                	push   $0x0
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 d6 01 00 00       	call   800acd <open>
  8008f7:	89 c3                	mov    %eax,%ebx
  8008f9:	83 c4 10             	add    $0x10,%esp
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	78 1b                	js     80091b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	ff 75 0c             	pushl  0xc(%ebp)
  800906:	50                   	push   %eax
  800907:	e8 5b ff ff ff       	call   800867 <fstat>
  80090c:	89 c6                	mov    %eax,%esi
	close(fd);
  80090e:	89 1c 24             	mov    %ebx,(%esp)
  800911:	e8 fd fb ff ff       	call   800513 <close>
	return r;
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	89 f0                	mov    %esi,%eax
}
  80091b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	89 c6                	mov    %eax,%esi
  800929:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800932:	75 12                	jne    800946 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800934:	83 ec 0c             	sub    $0xc,%esp
  800937:	6a 01                	push   $0x1
  800939:	e8 d9 15 00 00       	call   801f17 <ipc_find_env>
  80093e:	a3 00 40 80 00       	mov    %eax,0x804000
  800943:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800946:	6a 07                	push   $0x7
  800948:	68 00 50 80 00       	push   $0x805000
  80094d:	56                   	push   %esi
  80094e:	ff 35 00 40 80 00    	pushl  0x804000
  800954:	e8 6a 15 00 00       	call   801ec3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800959:	83 c4 0c             	add    $0xc,%esp
  80095c:	6a 00                	push   $0x0
  80095e:	53                   	push   %ebx
  80095f:	6a 00                	push   $0x0
  800961:	e8 f6 14 00 00       	call   801e5c <ipc_recv>
}
  800966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 40 0c             	mov    0xc(%eax),%eax
  800979:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800981:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
  80098b:	b8 02 00 00 00       	mov    $0x2,%eax
  800990:	e8 8d ff ff ff       	call   800922 <fsipc>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b2:	e8 6b ff ff ff       	call   800922 <fsipc>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	83 ec 04             	sub    $0x4,%esp
  8009c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d8:	e8 45 ff ff ff       	call   800922 <fsipc>
  8009dd:	85 c0                	test   %eax,%eax
  8009df:	78 2c                	js     800a0d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e1:	83 ec 08             	sub    $0x8,%esp
  8009e4:	68 00 50 80 00       	push   $0x805000
  8009e9:	53                   	push   %ebx
  8009ea:	e8 26 11 00 00       	call   801b15 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 0c             	sub    $0xc,%esp
  800a18:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a21:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a27:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a2c:	50                   	push   %eax
  800a2d:	ff 75 0c             	pushl  0xc(%ebp)
  800a30:	68 08 50 80 00       	push   $0x805008
  800a35:	e8 6d 12 00 00       	call   801ca7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a44:	e8 d9 fe ff ff       	call   800922 <fsipc>

}
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 40 0c             	mov    0xc(%eax),%eax
  800a59:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a5e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
  800a69:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6e:	e8 af fe ff ff       	call   800922 <fsipc>
  800a73:	89 c3                	mov    %eax,%ebx
  800a75:	85 c0                	test   %eax,%eax
  800a77:	78 4b                	js     800ac4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a79:	39 c6                	cmp    %eax,%esi
  800a7b:	73 16                	jae    800a93 <devfile_read+0x48>
  800a7d:	68 e8 22 80 00       	push   $0x8022e8
  800a82:	68 ef 22 80 00       	push   $0x8022ef
  800a87:	6a 7c                	push   $0x7c
  800a89:	68 04 23 80 00       	push   $0x802304
  800a8e:	e8 24 0a 00 00       	call   8014b7 <_panic>
	assert(r <= PGSIZE);
  800a93:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a98:	7e 16                	jle    800ab0 <devfile_read+0x65>
  800a9a:	68 0f 23 80 00       	push   $0x80230f
  800a9f:	68 ef 22 80 00       	push   $0x8022ef
  800aa4:	6a 7d                	push   $0x7d
  800aa6:	68 04 23 80 00       	push   $0x802304
  800aab:	e8 07 0a 00 00       	call   8014b7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab0:	83 ec 04             	sub    $0x4,%esp
  800ab3:	50                   	push   %eax
  800ab4:	68 00 50 80 00       	push   $0x805000
  800ab9:	ff 75 0c             	pushl  0xc(%ebp)
  800abc:	e8 e6 11 00 00       	call   801ca7 <memmove>
	return r;
  800ac1:	83 c4 10             	add    $0x10,%esp
}
  800ac4:	89 d8                	mov    %ebx,%eax
  800ac6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	53                   	push   %ebx
  800ad1:	83 ec 20             	sub    $0x20,%esp
  800ad4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ad7:	53                   	push   %ebx
  800ad8:	e8 ff 0f 00 00       	call   801adc <strlen>
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae5:	7f 67                	jg     800b4e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aed:	50                   	push   %eax
  800aee:	e8 a7 f8 ff ff       	call   80039a <fd_alloc>
  800af3:	83 c4 10             	add    $0x10,%esp
		return r;
  800af6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af8:	85 c0                	test   %eax,%eax
  800afa:	78 57                	js     800b53 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800afc:	83 ec 08             	sub    $0x8,%esp
  800aff:	53                   	push   %ebx
  800b00:	68 00 50 80 00       	push   $0x805000
  800b05:	e8 0b 10 00 00       	call   801b15 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b15:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1a:	e8 03 fe ff ff       	call   800922 <fsipc>
  800b1f:	89 c3                	mov    %eax,%ebx
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	85 c0                	test   %eax,%eax
  800b26:	79 14                	jns    800b3c <open+0x6f>
		fd_close(fd, 0);
  800b28:	83 ec 08             	sub    $0x8,%esp
  800b2b:	6a 00                	push   $0x0
  800b2d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b30:	e8 5d f9 ff ff       	call   800492 <fd_close>
		return r;
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	89 da                	mov    %ebx,%edx
  800b3a:	eb 17                	jmp    800b53 <open+0x86>
	}

	return fd2num(fd);
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b42:	e8 2c f8 ff ff       	call   800373 <fd2num>
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	83 c4 10             	add    $0x10,%esp
  800b4c:	eb 05                	jmp    800b53 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b4e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b53:	89 d0                	mov    %edx,%eax
  800b55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6a:	e8 b3 fd ff ff       	call   800922 <fsipc>
}
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	ff 75 08             	pushl  0x8(%ebp)
  800b7f:	e8 ff f7 ff ff       	call   800383 <fd2data>
  800b84:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b86:	83 c4 08             	add    $0x8,%esp
  800b89:	68 1b 23 80 00       	push   $0x80231b
  800b8e:	53                   	push   %ebx
  800b8f:	e8 81 0f 00 00       	call   801b15 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b94:	8b 46 04             	mov    0x4(%esi),%eax
  800b97:	2b 06                	sub    (%esi),%eax
  800b99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b9f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba6:	00 00 00 
	stat->st_dev = &devpipe;
  800ba9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb0:	30 80 00 
	return 0;
}
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc9:	53                   	push   %ebx
  800bca:	6a 00                	push   $0x0
  800bcc:	e8 17 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd1:	89 1c 24             	mov    %ebx,(%esp)
  800bd4:	e8 aa f7 ff ff       	call   800383 <fd2data>
  800bd9:	83 c4 08             	add    $0x8,%esp
  800bdc:	50                   	push   %eax
  800bdd:	6a 00                	push   $0x0
  800bdf:	e8 04 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800be4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 1c             	sub    $0x1c,%esp
  800bf2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bf5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bf7:	a1 08 40 80 00       	mov    0x804008,%eax
  800bfc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	ff 75 e0             	pushl  -0x20(%ebp)
  800c05:	e8 46 13 00 00       	call   801f50 <pageref>
  800c0a:	89 c3                	mov    %eax,%ebx
  800c0c:	89 3c 24             	mov    %edi,(%esp)
  800c0f:	e8 3c 13 00 00       	call   801f50 <pageref>
  800c14:	83 c4 10             	add    $0x10,%esp
  800c17:	39 c3                	cmp    %eax,%ebx
  800c19:	0f 94 c1             	sete   %cl
  800c1c:	0f b6 c9             	movzbl %cl,%ecx
  800c1f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c22:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c2b:	39 ce                	cmp    %ecx,%esi
  800c2d:	74 1b                	je     800c4a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c2f:	39 c3                	cmp    %eax,%ebx
  800c31:	75 c4                	jne    800bf7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c33:	8b 42 58             	mov    0x58(%edx),%eax
  800c36:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c39:	50                   	push   %eax
  800c3a:	56                   	push   %esi
  800c3b:	68 22 23 80 00       	push   $0x802322
  800c40:	e8 4b 09 00 00       	call   801590 <cprintf>
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	eb ad                	jmp    800bf7 <_pipeisclosed+0xe>
	}
}
  800c4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 28             	sub    $0x28,%esp
  800c5e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c61:	56                   	push   %esi
  800c62:	e8 1c f7 ff ff       	call   800383 <fd2data>
  800c67:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c71:	eb 4b                	jmp    800cbe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c73:	89 da                	mov    %ebx,%edx
  800c75:	89 f0                	mov    %esi,%eax
  800c77:	e8 6d ff ff ff       	call   800be9 <_pipeisclosed>
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	75 48                	jne    800cc8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c80:	e8 bf f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c85:	8b 43 04             	mov    0x4(%ebx),%eax
  800c88:	8b 0b                	mov    (%ebx),%ecx
  800c8a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c8d:	39 d0                	cmp    %edx,%eax
  800c8f:	73 e2                	jae    800c73 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c98:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9b:	89 c2                	mov    %eax,%edx
  800c9d:	c1 fa 1f             	sar    $0x1f,%edx
  800ca0:	89 d1                	mov    %edx,%ecx
  800ca2:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca8:	83 e2 1f             	and    $0x1f,%edx
  800cab:	29 ca                	sub    %ecx,%edx
  800cad:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb5:	83 c0 01             	add    $0x1,%eax
  800cb8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbb:	83 c7 01             	add    $0x1,%edi
  800cbe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc1:	75 c2                	jne    800c85 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc6:	eb 05                	jmp    800ccd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 18             	sub    $0x18,%esp
  800cde:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce1:	57                   	push   %edi
  800ce2:	e8 9c f6 ff ff       	call   800383 <fd2data>
  800ce7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	eb 3d                	jmp    800d30 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf3:	85 db                	test   %ebx,%ebx
  800cf5:	74 04                	je     800cfb <devpipe_read+0x26>
				return i;
  800cf7:	89 d8                	mov    %ebx,%eax
  800cf9:	eb 44                	jmp    800d3f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	89 f8                	mov    %edi,%eax
  800cff:	e8 e5 fe ff ff       	call   800be9 <_pipeisclosed>
  800d04:	85 c0                	test   %eax,%eax
  800d06:	75 32                	jne    800d3a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d08:	e8 37 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d0d:	8b 06                	mov    (%esi),%eax
  800d0f:	3b 46 04             	cmp    0x4(%esi),%eax
  800d12:	74 df                	je     800cf3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d14:	99                   	cltd   
  800d15:	c1 ea 1b             	shr    $0x1b,%edx
  800d18:	01 d0                	add    %edx,%eax
  800d1a:	83 e0 1f             	and    $0x1f,%eax
  800d1d:	29 d0                	sub    %edx,%eax
  800d1f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d2a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d2d:	83 c3 01             	add    $0x1,%ebx
  800d30:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d33:	75 d8                	jne    800d0d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d35:	8b 45 10             	mov    0x10(%ebp),%eax
  800d38:	eb 05                	jmp    800d3f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d3a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d52:	50                   	push   %eax
  800d53:	e8 42 f6 ff ff       	call   80039a <fd_alloc>
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	89 c2                	mov    %eax,%edx
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	0f 88 2c 01 00 00    	js     800e91 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d65:	83 ec 04             	sub    $0x4,%esp
  800d68:	68 07 04 00 00       	push   $0x407
  800d6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d70:	6a 00                	push   $0x0
  800d72:	e8 ec f3 ff ff       	call   800163 <sys_page_alloc>
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	0f 88 0d 01 00 00    	js     800e91 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8a:	50                   	push   %eax
  800d8b:	e8 0a f6 ff ff       	call   80039a <fd_alloc>
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	0f 88 e2 00 00 00    	js     800e7f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	68 07 04 00 00       	push   $0x407
  800da5:	ff 75 f0             	pushl  -0x10(%ebp)
  800da8:	6a 00                	push   $0x0
  800daa:	e8 b4 f3 ff ff       	call   800163 <sys_page_alloc>
  800daf:	89 c3                	mov    %eax,%ebx
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	0f 88 c3 00 00 00    	js     800e7f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc2:	e8 bc f5 ff ff       	call   800383 <fd2data>
  800dc7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc9:	83 c4 0c             	add    $0xc,%esp
  800dcc:	68 07 04 00 00       	push   $0x407
  800dd1:	50                   	push   %eax
  800dd2:	6a 00                	push   $0x0
  800dd4:	e8 8a f3 ff ff       	call   800163 <sys_page_alloc>
  800dd9:	89 c3                	mov    %eax,%ebx
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	0f 88 89 00 00 00    	js     800e6f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dec:	e8 92 f5 ff ff       	call   800383 <fd2data>
  800df1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df8:	50                   	push   %eax
  800df9:	6a 00                	push   $0x0
  800dfb:	56                   	push   %esi
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 a3 f3 ff ff       	call   8001a6 <sys_page_map>
  800e03:	89 c3                	mov    %eax,%ebx
  800e05:	83 c4 20             	add    $0x20,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	78 55                	js     800e61 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e0c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e15:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e21:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3c:	e8 32 f5 ff ff       	call   800373 <fd2num>
  800e41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e44:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e46:	83 c4 04             	add    $0x4,%esp
  800e49:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4c:	e8 22 f5 ff ff       	call   800373 <fd2num>
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e54:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5f:	eb 30                	jmp    800e91 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	56                   	push   %esi
  800e65:	6a 00                	push   $0x0
  800e67:	e8 7c f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	ff 75 f0             	pushl  -0x10(%ebp)
  800e75:	6a 00                	push   $0x0
  800e77:	e8 6c f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e7c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	ff 75 f4             	pushl  -0xc(%ebp)
  800e85:	6a 00                	push   $0x0
  800e87:	e8 5c f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e91:	89 d0                	mov    %edx,%eax
  800e93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea3:	50                   	push   %eax
  800ea4:	ff 75 08             	pushl  0x8(%ebp)
  800ea7:	e8 3d f5 ff ff       	call   8003e9 <fd_lookup>
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	78 18                	js     800ecb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb9:	e8 c5 f4 ff ff       	call   800383 <fd2data>
	return _pipeisclosed(fd, p);
  800ebe:	89 c2                	mov    %eax,%edx
  800ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec3:	e8 21 fd ff ff       	call   800be9 <_pipeisclosed>
  800ec8:	83 c4 10             	add    $0x10,%esp
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    

00800ecd <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ed3:	68 3a 23 80 00       	push   $0x80233a
  800ed8:	ff 75 0c             	pushl  0xc(%ebp)
  800edb:	e8 35 0c 00 00       	call   801b15 <strcpy>
	return 0;
}
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 10             	sub    $0x10,%esp
  800eee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800ef1:	53                   	push   %ebx
  800ef2:	e8 59 10 00 00       	call   801f50 <pageref>
  800ef7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800eff:	83 f8 01             	cmp    $0x1,%eax
  800f02:	75 10                	jne    800f14 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	ff 73 0c             	pushl  0xc(%ebx)
  800f0a:	e8 c0 02 00 00       	call   8011cf <nsipc_close>
  800f0f:	89 c2                	mov    %eax,%edx
  800f11:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f14:	89 d0                	mov    %edx,%eax
  800f16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f21:	6a 00                	push   $0x0
  800f23:	ff 75 10             	pushl  0x10(%ebp)
  800f26:	ff 75 0c             	pushl  0xc(%ebp)
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	ff 70 0c             	pushl  0xc(%eax)
  800f2f:	e8 78 03 00 00       	call   8012ac <nsipc_send>
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f3c:	6a 00                	push   $0x0
  800f3e:	ff 75 10             	pushl  0x10(%ebp)
  800f41:	ff 75 0c             	pushl  0xc(%ebp)
  800f44:	8b 45 08             	mov    0x8(%ebp),%eax
  800f47:	ff 70 0c             	pushl  0xc(%eax)
  800f4a:	e8 f1 02 00 00       	call   801240 <nsipc_recv>
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f57:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f5a:	52                   	push   %edx
  800f5b:	50                   	push   %eax
  800f5c:	e8 88 f4 ff ff       	call   8003e9 <fd_lookup>
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 17                	js     800f7f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6b:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f71:	39 08                	cmp    %ecx,(%eax)
  800f73:	75 05                	jne    800f7a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f75:	8b 40 0c             	mov    0xc(%eax),%eax
  800f78:	eb 05                	jmp    800f7f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f7a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 1c             	sub    $0x1c,%esp
  800f89:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	e8 06 f4 ff ff       	call   80039a <fd_alloc>
  800f94:	89 c3                	mov    %eax,%ebx
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 1b                	js     800fb8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	68 07 04 00 00       	push   $0x407
  800fa5:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa8:	6a 00                	push   $0x0
  800faa:	e8 b4 f1 ff ff       	call   800163 <sys_page_alloc>
  800faf:	89 c3                	mov    %eax,%ebx
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	79 10                	jns    800fc8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	56                   	push   %esi
  800fbc:	e8 0e 02 00 00       	call   8011cf <nsipc_close>
		return r;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	89 d8                	mov    %ebx,%eax
  800fc6:	eb 24                	jmp    800fec <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fc8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800fdd:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	50                   	push   %eax
  800fe4:	e8 8a f3 ff ff       	call   800373 <fd2num>
  800fe9:	83 c4 10             	add    $0x10,%esp
}
  800fec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffc:	e8 50 ff ff ff       	call   800f51 <fd2sockid>
		return r;
  801001:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801003:	85 c0                	test   %eax,%eax
  801005:	78 1f                	js     801026 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	ff 75 10             	pushl  0x10(%ebp)
  80100d:	ff 75 0c             	pushl  0xc(%ebp)
  801010:	50                   	push   %eax
  801011:	e8 12 01 00 00       	call   801128 <nsipc_accept>
  801016:	83 c4 10             	add    $0x10,%esp
		return r;
  801019:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 07                	js     801026 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80101f:	e8 5d ff ff ff       	call   800f81 <alloc_sockfd>
  801024:	89 c1                	mov    %eax,%ecx
}
  801026:	89 c8                	mov    %ecx,%eax
  801028:	c9                   	leave  
  801029:	c3                   	ret    

0080102a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	e8 19 ff ff ff       	call   800f51 <fd2sockid>
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 12                	js     80104e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	ff 75 10             	pushl  0x10(%ebp)
  801042:	ff 75 0c             	pushl  0xc(%ebp)
  801045:	50                   	push   %eax
  801046:	e8 2d 01 00 00       	call   801178 <nsipc_bind>
  80104b:	83 c4 10             	add    $0x10,%esp
}
  80104e:	c9                   	leave  
  80104f:	c3                   	ret    

00801050 <shutdown>:

int
shutdown(int s, int how)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801056:	8b 45 08             	mov    0x8(%ebp),%eax
  801059:	e8 f3 fe ff ff       	call   800f51 <fd2sockid>
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 0f                	js     801071 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801062:	83 ec 08             	sub    $0x8,%esp
  801065:	ff 75 0c             	pushl  0xc(%ebp)
  801068:	50                   	push   %eax
  801069:	e8 3f 01 00 00       	call   8011ad <nsipc_shutdown>
  80106e:	83 c4 10             	add    $0x10,%esp
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
  80107c:	e8 d0 fe ff ff       	call   800f51 <fd2sockid>
  801081:	85 c0                	test   %eax,%eax
  801083:	78 12                	js     801097 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	ff 75 10             	pushl  0x10(%ebp)
  80108b:	ff 75 0c             	pushl  0xc(%ebp)
  80108e:	50                   	push   %eax
  80108f:	e8 55 01 00 00       	call   8011e9 <nsipc_connect>
  801094:	83 c4 10             	add    $0x10,%esp
}
  801097:	c9                   	leave  
  801098:	c3                   	ret    

00801099 <listen>:

int
listen(int s, int backlog)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a2:	e8 aa fe ff ff       	call   800f51 <fd2sockid>
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 0f                	js     8010ba <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	ff 75 0c             	pushl  0xc(%ebp)
  8010b1:	50                   	push   %eax
  8010b2:	e8 67 01 00 00       	call   80121e <nsipc_listen>
  8010b7:	83 c4 10             	add    $0x10,%esp
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010c2:	ff 75 10             	pushl  0x10(%ebp)
  8010c5:	ff 75 0c             	pushl  0xc(%ebp)
  8010c8:	ff 75 08             	pushl  0x8(%ebp)
  8010cb:	e8 3a 02 00 00       	call   80130a <nsipc_socket>
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	78 05                	js     8010dc <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010d7:	e8 a5 fe ff ff       	call   800f81 <alloc_sockfd>
}
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 04             	sub    $0x4,%esp
  8010e5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8010e7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8010ee:	75 12                	jne    801102 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	6a 02                	push   $0x2
  8010f5:	e8 1d 0e 00 00       	call   801f17 <ipc_find_env>
  8010fa:	a3 04 40 80 00       	mov    %eax,0x804004
  8010ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801102:	6a 07                	push   $0x7
  801104:	68 00 60 80 00       	push   $0x806000
  801109:	53                   	push   %ebx
  80110a:	ff 35 04 40 80 00    	pushl  0x804004
  801110:	e8 ae 0d 00 00       	call   801ec3 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801115:	83 c4 0c             	add    $0xc,%esp
  801118:	6a 00                	push   $0x0
  80111a:	6a 00                	push   $0x0
  80111c:	6a 00                	push   $0x0
  80111e:	e8 39 0d 00 00       	call   801e5c <ipc_recv>
}
  801123:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801138:	8b 06                	mov    (%esi),%eax
  80113a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80113f:	b8 01 00 00 00       	mov    $0x1,%eax
  801144:	e8 95 ff ff ff       	call   8010de <nsipc>
  801149:	89 c3                	mov    %eax,%ebx
  80114b:	85 c0                	test   %eax,%eax
  80114d:	78 20                	js     80116f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	ff 35 10 60 80 00    	pushl  0x806010
  801158:	68 00 60 80 00       	push   $0x806000
  80115d:	ff 75 0c             	pushl  0xc(%ebp)
  801160:	e8 42 0b 00 00       	call   801ca7 <memmove>
		*addrlen = ret->ret_addrlen;
  801165:	a1 10 60 80 00       	mov    0x806010,%eax
  80116a:	89 06                	mov    %eax,(%esi)
  80116c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80116f:	89 d8                	mov    %ebx,%eax
  801171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	53                   	push   %ebx
  80117c:	83 ec 08             	sub    $0x8,%esp
  80117f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80118a:	53                   	push   %ebx
  80118b:	ff 75 0c             	pushl  0xc(%ebp)
  80118e:	68 04 60 80 00       	push   $0x806004
  801193:	e8 0f 0b 00 00       	call   801ca7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801198:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80119e:	b8 02 00 00 00       	mov    $0x2,%eax
  8011a3:	e8 36 ff ff ff       	call   8010de <nsipc>
}
  8011a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    

008011ad <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011be:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011c3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011c8:	e8 11 ff ff ff       	call   8010de <nsipc>
}
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    

008011cf <nsipc_close>:

int
nsipc_close(int s)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011dd:	b8 04 00 00 00       	mov    $0x4,%eax
  8011e2:	e8 f7 fe ff ff       	call   8010de <nsipc>
}
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 08             	sub    $0x8,%esp
  8011f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8011fb:	53                   	push   %ebx
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	68 04 60 80 00       	push   $0x806004
  801204:	e8 9e 0a 00 00       	call   801ca7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801209:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80120f:	b8 05 00 00 00       	mov    $0x5,%eax
  801214:	e8 c5 fe ff ff       	call   8010de <nsipc>
}
  801219:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801224:	8b 45 08             	mov    0x8(%ebp),%eax
  801227:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80122c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801234:	b8 06 00 00 00       	mov    $0x6,%eax
  801239:	e8 a0 fe ff ff       	call   8010de <nsipc>
}
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	56                   	push   %esi
  801244:	53                   	push   %ebx
  801245:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801248:	8b 45 08             	mov    0x8(%ebp),%eax
  80124b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801250:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801256:	8b 45 14             	mov    0x14(%ebp),%eax
  801259:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80125e:	b8 07 00 00 00       	mov    $0x7,%eax
  801263:	e8 76 fe ff ff       	call   8010de <nsipc>
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 35                	js     8012a3 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80126e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801273:	7f 04                	jg     801279 <nsipc_recv+0x39>
  801275:	39 c6                	cmp    %eax,%esi
  801277:	7d 16                	jge    80128f <nsipc_recv+0x4f>
  801279:	68 46 23 80 00       	push   $0x802346
  80127e:	68 ef 22 80 00       	push   $0x8022ef
  801283:	6a 62                	push   $0x62
  801285:	68 5b 23 80 00       	push   $0x80235b
  80128a:	e8 28 02 00 00       	call   8014b7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	50                   	push   %eax
  801293:	68 00 60 80 00       	push   $0x806000
  801298:	ff 75 0c             	pushl  0xc(%ebp)
  80129b:	e8 07 0a 00 00       	call   801ca7 <memmove>
  8012a0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012a3:	89 d8                	mov    %ebx,%eax
  8012a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a8:	5b                   	pop    %ebx
  8012a9:	5e                   	pop    %esi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 04             	sub    $0x4,%esp
  8012b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b9:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012be:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012c4:	7e 16                	jle    8012dc <nsipc_send+0x30>
  8012c6:	68 67 23 80 00       	push   $0x802367
  8012cb:	68 ef 22 80 00       	push   $0x8022ef
  8012d0:	6a 6d                	push   $0x6d
  8012d2:	68 5b 23 80 00       	push   $0x80235b
  8012d7:	e8 db 01 00 00       	call   8014b7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012dc:	83 ec 04             	sub    $0x4,%esp
  8012df:	53                   	push   %ebx
  8012e0:	ff 75 0c             	pushl  0xc(%ebp)
  8012e3:	68 0c 60 80 00       	push   $0x80600c
  8012e8:	e8 ba 09 00 00       	call   801ca7 <memmove>
	nsipcbuf.send.req_size = size;
  8012ed:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8012f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8012fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801300:	e8 d9 fd ff ff       	call   8010de <nsipc>
}
  801305:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801308:	c9                   	leave  
  801309:	c3                   	ret    

0080130a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80130a:	55                   	push   %ebp
  80130b:	89 e5                	mov    %esp,%ebp
  80130d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
  801313:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801320:	8b 45 10             	mov    0x10(%ebp),%eax
  801323:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801328:	b8 09 00 00 00       	mov    $0x9,%eax
  80132d:	e8 ac fd ff ff       	call   8010de <nsipc>
}
  801332:	c9                   	leave  
  801333:	c3                   	ret    

00801334 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801337:	b8 00 00 00 00       	mov    $0x0,%eax
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801344:	68 73 23 80 00       	push   $0x802373
  801349:	ff 75 0c             	pushl  0xc(%ebp)
  80134c:	e8 c4 07 00 00       	call   801b15 <strcpy>
	return 0;
}
  801351:	b8 00 00 00 00       	mov    $0x0,%eax
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	57                   	push   %edi
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
  80135e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801364:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801369:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80136f:	eb 2d                	jmp    80139e <devcons_write+0x46>
		m = n - tot;
  801371:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801374:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801376:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801379:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80137e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801381:	83 ec 04             	sub    $0x4,%esp
  801384:	53                   	push   %ebx
  801385:	03 45 0c             	add    0xc(%ebp),%eax
  801388:	50                   	push   %eax
  801389:	57                   	push   %edi
  80138a:	e8 18 09 00 00       	call   801ca7 <memmove>
		sys_cputs(buf, m);
  80138f:	83 c4 08             	add    $0x8,%esp
  801392:	53                   	push   %ebx
  801393:	57                   	push   %edi
  801394:	e8 0e ed ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801399:	01 de                	add    %ebx,%esi
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a3:	72 cc                	jb     801371 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013bc:	74 2a                	je     8013e8 <devcons_read+0x3b>
  8013be:	eb 05                	jmp    8013c5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013c0:	e8 7f ed ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013c5:	e8 fb ec ff ff       	call   8000c5 <sys_cgetc>
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	74 f2                	je     8013c0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 16                	js     8013e8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013d2:	83 f8 04             	cmp    $0x4,%eax
  8013d5:	74 0c                	je     8013e3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013da:	88 02                	mov    %al,(%edx)
	return 1;
  8013dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e1:	eb 05                	jmp    8013e8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013e3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013f6:	6a 01                	push   $0x1
  8013f8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	e8 a6 ec ff ff       	call   8000a7 <sys_cputs>
}
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <getchar>:

int
getchar(void)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80140c:	6a 01                	push   $0x1
  80140e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801411:	50                   	push   %eax
  801412:	6a 00                	push   $0x0
  801414:	e8 36 f2 ff ff       	call   80064f <read>
	if (r < 0)
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 0f                	js     80142f <getchar+0x29>
		return r;
	if (r < 1)
  801420:	85 c0                	test   %eax,%eax
  801422:	7e 06                	jle    80142a <getchar+0x24>
		return -E_EOF;
	return c;
  801424:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801428:	eb 05                	jmp    80142f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80142a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801437:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	ff 75 08             	pushl  0x8(%ebp)
  80143e:	e8 a6 ef ff ff       	call   8003e9 <fd_lookup>
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 11                	js     80145b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801453:	39 10                	cmp    %edx,(%eax)
  801455:	0f 94 c0             	sete   %al
  801458:	0f b6 c0             	movzbl %al,%eax
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <opencons>:

int
opencons(void)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801463:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	e8 2e ef ff ff       	call   80039a <fd_alloc>
  80146c:	83 c4 10             	add    $0x10,%esp
		return r;
  80146f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801471:	85 c0                	test   %eax,%eax
  801473:	78 3e                	js     8014b3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801475:	83 ec 04             	sub    $0x4,%esp
  801478:	68 07 04 00 00       	push   $0x407
  80147d:	ff 75 f4             	pushl  -0xc(%ebp)
  801480:	6a 00                	push   $0x0
  801482:	e8 dc ec ff ff       	call   800163 <sys_page_alloc>
  801487:	83 c4 10             	add    $0x10,%esp
		return r;
  80148a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 23                	js     8014b3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801490:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801496:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801499:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80149b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	50                   	push   %eax
  8014a9:	e8 c5 ee ff ff       	call   800373 <fd2num>
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	83 c4 10             	add    $0x10,%esp
}
  8014b3:	89 d0                	mov    %edx,%eax
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	56                   	push   %esi
  8014bb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014bc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014bf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c5:	e8 5b ec ff ff       	call   800125 <sys_getenvid>
  8014ca:	83 ec 0c             	sub    $0xc,%esp
  8014cd:	ff 75 0c             	pushl  0xc(%ebp)
  8014d0:	ff 75 08             	pushl  0x8(%ebp)
  8014d3:	56                   	push   %esi
  8014d4:	50                   	push   %eax
  8014d5:	68 80 23 80 00       	push   $0x802380
  8014da:	e8 b1 00 00 00       	call   801590 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014df:	83 c4 18             	add    $0x18,%esp
  8014e2:	53                   	push   %ebx
  8014e3:	ff 75 10             	pushl  0x10(%ebp)
  8014e6:	e8 54 00 00 00       	call   80153f <vcprintf>
	cprintf("\n");
  8014eb:	c7 04 24 33 23 80 00 	movl   $0x802333,(%esp)
  8014f2:	e8 99 00 00 00       	call   801590 <cprintf>
  8014f7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014fa:	cc                   	int3   
  8014fb:	eb fd                	jmp    8014fa <_panic+0x43>

008014fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801507:	8b 13                	mov    (%ebx),%edx
  801509:	8d 42 01             	lea    0x1(%edx),%eax
  80150c:	89 03                	mov    %eax,(%ebx)
  80150e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801511:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801515:	3d ff 00 00 00       	cmp    $0xff,%eax
  80151a:	75 1a                	jne    801536 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	68 ff 00 00 00       	push   $0xff
  801524:	8d 43 08             	lea    0x8(%ebx),%eax
  801527:	50                   	push   %eax
  801528:	e8 7a eb ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  80152d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801533:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801536:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801548:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80154f:	00 00 00 
	b.cnt = 0;
  801552:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801559:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80155c:	ff 75 0c             	pushl  0xc(%ebp)
  80155f:	ff 75 08             	pushl  0x8(%ebp)
  801562:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	68 fd 14 80 00       	push   $0x8014fd
  80156e:	e8 54 01 00 00       	call   8016c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801573:	83 c4 08             	add    $0x8,%esp
  801576:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80157c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	e8 1f eb ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801588:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801596:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801599:	50                   	push   %eax
  80159a:	ff 75 08             	pushl  0x8(%ebp)
  80159d:	e8 9d ff ff ff       	call   80153f <vcprintf>
	va_end(ap);

	return cnt;
}
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	57                   	push   %edi
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 1c             	sub    $0x1c,%esp
  8015ad:	89 c7                	mov    %eax,%edi
  8015af:	89 d6                	mov    %edx,%esi
  8015b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015c8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015cb:	39 d3                	cmp    %edx,%ebx
  8015cd:	72 05                	jb     8015d4 <printnum+0x30>
  8015cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015d2:	77 45                	ja     801619 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	ff 75 18             	pushl  0x18(%ebp)
  8015da:	8b 45 14             	mov    0x14(%ebp),%eax
  8015dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015e0:	53                   	push   %ebx
  8015e1:	ff 75 10             	pushl  0x10(%ebp)
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8015f3:	e8 98 09 00 00       	call   801f90 <__udivdi3>
  8015f8:	83 c4 18             	add    $0x18,%esp
  8015fb:	52                   	push   %edx
  8015fc:	50                   	push   %eax
  8015fd:	89 f2                	mov    %esi,%edx
  8015ff:	89 f8                	mov    %edi,%eax
  801601:	e8 9e ff ff ff       	call   8015a4 <printnum>
  801606:	83 c4 20             	add    $0x20,%esp
  801609:	eb 18                	jmp    801623 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	56                   	push   %esi
  80160f:	ff 75 18             	pushl  0x18(%ebp)
  801612:	ff d7                	call   *%edi
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb 03                	jmp    80161c <printnum+0x78>
  801619:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80161c:	83 eb 01             	sub    $0x1,%ebx
  80161f:	85 db                	test   %ebx,%ebx
  801621:	7f e8                	jg     80160b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	56                   	push   %esi
  801627:	83 ec 04             	sub    $0x4,%esp
  80162a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162d:	ff 75 e0             	pushl  -0x20(%ebp)
  801630:	ff 75 dc             	pushl  -0x24(%ebp)
  801633:	ff 75 d8             	pushl  -0x28(%ebp)
  801636:	e8 85 0a 00 00       	call   8020c0 <__umoddi3>
  80163b:	83 c4 14             	add    $0x14,%esp
  80163e:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  801645:	50                   	push   %eax
  801646:	ff d7                	call   *%edi
}
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5f                   	pop    %edi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801656:	83 fa 01             	cmp    $0x1,%edx
  801659:	7e 0e                	jle    801669 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80165b:	8b 10                	mov    (%eax),%edx
  80165d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801660:	89 08                	mov    %ecx,(%eax)
  801662:	8b 02                	mov    (%edx),%eax
  801664:	8b 52 04             	mov    0x4(%edx),%edx
  801667:	eb 22                	jmp    80168b <getuint+0x38>
	else if (lflag)
  801669:	85 d2                	test   %edx,%edx
  80166b:	74 10                	je     80167d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80166d:	8b 10                	mov    (%eax),%edx
  80166f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801672:	89 08                	mov    %ecx,(%eax)
  801674:	8b 02                	mov    (%edx),%eax
  801676:	ba 00 00 00 00       	mov    $0x0,%edx
  80167b:	eb 0e                	jmp    80168b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80167d:	8b 10                	mov    (%eax),%edx
  80167f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801682:	89 08                	mov    %ecx,(%eax)
  801684:	8b 02                	mov    (%edx),%eax
  801686:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80168b:	5d                   	pop    %ebp
  80168c:	c3                   	ret    

0080168d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801693:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801697:	8b 10                	mov    (%eax),%edx
  801699:	3b 50 04             	cmp    0x4(%eax),%edx
  80169c:	73 0a                	jae    8016a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80169e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016a1:	89 08                	mov    %ecx,(%eax)
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	88 02                	mov    %al,(%edx)
}
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016b3:	50                   	push   %eax
  8016b4:	ff 75 10             	pushl  0x10(%ebp)
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	ff 75 08             	pushl  0x8(%ebp)
  8016bd:	e8 05 00 00 00       	call   8016c7 <vprintfmt>
	va_end(ap);
}
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	57                   	push   %edi
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 2c             	sub    $0x2c,%esp
  8016d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016d9:	eb 12                	jmp    8016ed <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	0f 84 89 03 00 00    	je     801a6c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	53                   	push   %ebx
  8016e7:	50                   	push   %eax
  8016e8:	ff d6                	call   *%esi
  8016ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016ed:	83 c7 01             	add    $0x1,%edi
  8016f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016f4:	83 f8 25             	cmp    $0x25,%eax
  8016f7:	75 e2                	jne    8016db <vprintfmt+0x14>
  8016f9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801704:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80170b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801712:	ba 00 00 00 00       	mov    $0x0,%edx
  801717:	eb 07                	jmp    801720 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801719:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80171c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801720:	8d 47 01             	lea    0x1(%edi),%eax
  801723:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801726:	0f b6 07             	movzbl (%edi),%eax
  801729:	0f b6 c8             	movzbl %al,%ecx
  80172c:	83 e8 23             	sub    $0x23,%eax
  80172f:	3c 55                	cmp    $0x55,%al
  801731:	0f 87 1a 03 00 00    	ja     801a51 <vprintfmt+0x38a>
  801737:	0f b6 c0             	movzbl %al,%eax
  80173a:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801744:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801748:	eb d6                	jmp    801720 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
  801752:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801755:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801758:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80175c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80175f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801762:	83 fa 09             	cmp    $0x9,%edx
  801765:	77 39                	ja     8017a0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801767:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80176a:	eb e9                	jmp    801755 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80176c:	8b 45 14             	mov    0x14(%ebp),%eax
  80176f:	8d 48 04             	lea    0x4(%eax),%ecx
  801772:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801775:	8b 00                	mov    (%eax),%eax
  801777:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80177d:	eb 27                	jmp    8017a6 <vprintfmt+0xdf>
  80177f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801782:	85 c0                	test   %eax,%eax
  801784:	b9 00 00 00 00       	mov    $0x0,%ecx
  801789:	0f 49 c8             	cmovns %eax,%ecx
  80178c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801792:	eb 8c                	jmp    801720 <vprintfmt+0x59>
  801794:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801797:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80179e:	eb 80                	jmp    801720 <vprintfmt+0x59>
  8017a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017a3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017aa:	0f 89 70 ff ff ff    	jns    801720 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017bd:	e9 5e ff ff ff       	jmp    801720 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017c2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017c8:	e9 53 ff ff ff       	jmp    801720 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d0:	8d 50 04             	lea    0x4(%eax),%edx
  8017d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8017d6:	83 ec 08             	sub    $0x8,%esp
  8017d9:	53                   	push   %ebx
  8017da:	ff 30                	pushl  (%eax)
  8017dc:	ff d6                	call   *%esi
			break;
  8017de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017e4:	e9 04 ff ff ff       	jmp    8016ed <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ec:	8d 50 04             	lea    0x4(%eax),%edx
  8017ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f2:	8b 00                	mov    (%eax),%eax
  8017f4:	99                   	cltd   
  8017f5:	31 d0                	xor    %edx,%eax
  8017f7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f9:	83 f8 0f             	cmp    $0xf,%eax
  8017fc:	7f 0b                	jg     801809 <vprintfmt+0x142>
  8017fe:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  801805:	85 d2                	test   %edx,%edx
  801807:	75 18                	jne    801821 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801809:	50                   	push   %eax
  80180a:	68 bb 23 80 00       	push   $0x8023bb
  80180f:	53                   	push   %ebx
  801810:	56                   	push   %esi
  801811:	e8 94 fe ff ff       	call   8016aa <printfmt>
  801816:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801819:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80181c:	e9 cc fe ff ff       	jmp    8016ed <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801821:	52                   	push   %edx
  801822:	68 01 23 80 00       	push   $0x802301
  801827:	53                   	push   %ebx
  801828:	56                   	push   %esi
  801829:	e8 7c fe ff ff       	call   8016aa <printfmt>
  80182e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801831:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801834:	e9 b4 fe ff ff       	jmp    8016ed <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801839:	8b 45 14             	mov    0x14(%ebp),%eax
  80183c:	8d 50 04             	lea    0x4(%eax),%edx
  80183f:	89 55 14             	mov    %edx,0x14(%ebp)
  801842:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801844:	85 ff                	test   %edi,%edi
  801846:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  80184b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80184e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801852:	0f 8e 94 00 00 00    	jle    8018ec <vprintfmt+0x225>
  801858:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80185c:	0f 84 98 00 00 00    	je     8018fa <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	ff 75 d0             	pushl  -0x30(%ebp)
  801868:	57                   	push   %edi
  801869:	e8 86 02 00 00       	call   801af4 <strnlen>
  80186e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801871:	29 c1                	sub    %eax,%ecx
  801873:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801876:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801879:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80187d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801880:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801883:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801885:	eb 0f                	jmp    801896 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	53                   	push   %ebx
  80188b:	ff 75 e0             	pushl  -0x20(%ebp)
  80188e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801890:	83 ef 01             	sub    $0x1,%edi
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	85 ff                	test   %edi,%edi
  801898:	7f ed                	jg     801887 <vprintfmt+0x1c0>
  80189a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80189d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018a0:	85 c9                	test   %ecx,%ecx
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a7:	0f 49 c1             	cmovns %ecx,%eax
  8018aa:	29 c1                	sub    %eax,%ecx
  8018ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8018af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018b5:	89 cb                	mov    %ecx,%ebx
  8018b7:	eb 4d                	jmp    801906 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018bd:	74 1b                	je     8018da <vprintfmt+0x213>
  8018bf:	0f be c0             	movsbl %al,%eax
  8018c2:	83 e8 20             	sub    $0x20,%eax
  8018c5:	83 f8 5e             	cmp    $0x5e,%eax
  8018c8:	76 10                	jbe    8018da <vprintfmt+0x213>
					putch('?', putdat);
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	ff 75 0c             	pushl  0xc(%ebp)
  8018d0:	6a 3f                	push   $0x3f
  8018d2:	ff 55 08             	call   *0x8(%ebp)
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	eb 0d                	jmp    8018e7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018da:	83 ec 08             	sub    $0x8,%esp
  8018dd:	ff 75 0c             	pushl  0xc(%ebp)
  8018e0:	52                   	push   %edx
  8018e1:	ff 55 08             	call   *0x8(%ebp)
  8018e4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018e7:	83 eb 01             	sub    $0x1,%ebx
  8018ea:	eb 1a                	jmp    801906 <vprintfmt+0x23f>
  8018ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018f8:	eb 0c                	jmp    801906 <vprintfmt+0x23f>
  8018fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8018fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801900:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801903:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801906:	83 c7 01             	add    $0x1,%edi
  801909:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80190d:	0f be d0             	movsbl %al,%edx
  801910:	85 d2                	test   %edx,%edx
  801912:	74 23                	je     801937 <vprintfmt+0x270>
  801914:	85 f6                	test   %esi,%esi
  801916:	78 a1                	js     8018b9 <vprintfmt+0x1f2>
  801918:	83 ee 01             	sub    $0x1,%esi
  80191b:	79 9c                	jns    8018b9 <vprintfmt+0x1f2>
  80191d:	89 df                	mov    %ebx,%edi
  80191f:	8b 75 08             	mov    0x8(%ebp),%esi
  801922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801925:	eb 18                	jmp    80193f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	53                   	push   %ebx
  80192b:	6a 20                	push   $0x20
  80192d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80192f:	83 ef 01             	sub    $0x1,%edi
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	eb 08                	jmp    80193f <vprintfmt+0x278>
  801937:	89 df                	mov    %ebx,%edi
  801939:	8b 75 08             	mov    0x8(%ebp),%esi
  80193c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80193f:	85 ff                	test   %edi,%edi
  801941:	7f e4                	jg     801927 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801943:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801946:	e9 a2 fd ff ff       	jmp    8016ed <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80194b:	83 fa 01             	cmp    $0x1,%edx
  80194e:	7e 16                	jle    801966 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801950:	8b 45 14             	mov    0x14(%ebp),%eax
  801953:	8d 50 08             	lea    0x8(%eax),%edx
  801956:	89 55 14             	mov    %edx,0x14(%ebp)
  801959:	8b 50 04             	mov    0x4(%eax),%edx
  80195c:	8b 00                	mov    (%eax),%eax
  80195e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801961:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801964:	eb 32                	jmp    801998 <vprintfmt+0x2d1>
	else if (lflag)
  801966:	85 d2                	test   %edx,%edx
  801968:	74 18                	je     801982 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80196a:	8b 45 14             	mov    0x14(%ebp),%eax
  80196d:	8d 50 04             	lea    0x4(%eax),%edx
  801970:	89 55 14             	mov    %edx,0x14(%ebp)
  801973:	8b 00                	mov    (%eax),%eax
  801975:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801978:	89 c1                	mov    %eax,%ecx
  80197a:	c1 f9 1f             	sar    $0x1f,%ecx
  80197d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801980:	eb 16                	jmp    801998 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801982:	8b 45 14             	mov    0x14(%ebp),%eax
  801985:	8d 50 04             	lea    0x4(%eax),%edx
  801988:	89 55 14             	mov    %edx,0x14(%ebp)
  80198b:	8b 00                	mov    (%eax),%eax
  80198d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801990:	89 c1                	mov    %eax,%ecx
  801992:	c1 f9 1f             	sar    $0x1f,%ecx
  801995:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801998:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80199b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80199e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019a7:	79 74                	jns    801a1d <vprintfmt+0x356>
				putch('-', putdat);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	6a 2d                	push   $0x2d
  8019af:	ff d6                	call   *%esi
				num = -(long long) num;
  8019b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019b7:	f7 d8                	neg    %eax
  8019b9:	83 d2 00             	adc    $0x0,%edx
  8019bc:	f7 da                	neg    %edx
  8019be:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019c6:	eb 55                	jmp    801a1d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8019cb:	e8 83 fc ff ff       	call   801653 <getuint>
			base = 10;
  8019d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019d5:	eb 46                	jmp    801a1d <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8019d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8019da:	e8 74 fc ff ff       	call   801653 <getuint>
			base = 8;
  8019df:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019e4:	eb 37                	jmp    801a1d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	53                   	push   %ebx
  8019ea:	6a 30                	push   $0x30
  8019ec:	ff d6                	call   *%esi
			putch('x', putdat);
  8019ee:	83 c4 08             	add    $0x8,%esp
  8019f1:	53                   	push   %ebx
  8019f2:	6a 78                	push   $0x78
  8019f4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f9:	8d 50 04             	lea    0x4(%eax),%edx
  8019fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019ff:	8b 00                	mov    (%eax),%eax
  801a01:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a06:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a09:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a0e:	eb 0d                	jmp    801a1d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a10:	8d 45 14             	lea    0x14(%ebp),%eax
  801a13:	e8 3b fc ff ff       	call   801653 <getuint>
			base = 16;
  801a18:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a24:	57                   	push   %edi
  801a25:	ff 75 e0             	pushl  -0x20(%ebp)
  801a28:	51                   	push   %ecx
  801a29:	52                   	push   %edx
  801a2a:	50                   	push   %eax
  801a2b:	89 da                	mov    %ebx,%edx
  801a2d:	89 f0                	mov    %esi,%eax
  801a2f:	e8 70 fb ff ff       	call   8015a4 <printnum>
			break;
  801a34:	83 c4 20             	add    $0x20,%esp
  801a37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a3a:	e9 ae fc ff ff       	jmp    8016ed <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a3f:	83 ec 08             	sub    $0x8,%esp
  801a42:	53                   	push   %ebx
  801a43:	51                   	push   %ecx
  801a44:	ff d6                	call   *%esi
			break;
  801a46:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a4c:	e9 9c fc ff ff       	jmp    8016ed <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	53                   	push   %ebx
  801a55:	6a 25                	push   $0x25
  801a57:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	eb 03                	jmp    801a61 <vprintfmt+0x39a>
  801a5e:	83 ef 01             	sub    $0x1,%edi
  801a61:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a65:	75 f7                	jne    801a5e <vprintfmt+0x397>
  801a67:	e9 81 fc ff ff       	jmp    8016ed <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 18             	sub    $0x18,%esp
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a80:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a83:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a87:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a91:	85 c0                	test   %eax,%eax
  801a93:	74 26                	je     801abb <vsnprintf+0x47>
  801a95:	85 d2                	test   %edx,%edx
  801a97:	7e 22                	jle    801abb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a99:	ff 75 14             	pushl  0x14(%ebp)
  801a9c:	ff 75 10             	pushl  0x10(%ebp)
  801a9f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	68 8d 16 80 00       	push   $0x80168d
  801aa8:	e8 1a fc ff ff       	call   8016c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ab0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	eb 05                	jmp    801ac0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801abb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ac8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801acb:	50                   	push   %eax
  801acc:	ff 75 10             	pushl  0x10(%ebp)
  801acf:	ff 75 0c             	pushl  0xc(%ebp)
  801ad2:	ff 75 08             	pushl  0x8(%ebp)
  801ad5:	e8 9a ff ff ff       	call   801a74 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae7:	eb 03                	jmp    801aec <strlen+0x10>
		n++;
  801ae9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801aec:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801af0:	75 f7                	jne    801ae9 <strlen+0xd>
		n++;
	return n;
}
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801afd:	ba 00 00 00 00       	mov    $0x0,%edx
  801b02:	eb 03                	jmp    801b07 <strnlen+0x13>
		n++;
  801b04:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b07:	39 c2                	cmp    %eax,%edx
  801b09:	74 08                	je     801b13 <strnlen+0x1f>
  801b0b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b0f:	75 f3                	jne    801b04 <strnlen+0x10>
  801b11:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	83 c2 01             	add    $0x1,%edx
  801b24:	83 c1 01             	add    $0x1,%ecx
  801b27:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b2b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b2e:	84 db                	test   %bl,%bl
  801b30:	75 ef                	jne    801b21 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b32:	5b                   	pop    %ebx
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	53                   	push   %ebx
  801b39:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b3c:	53                   	push   %ebx
  801b3d:	e8 9a ff ff ff       	call   801adc <strlen>
  801b42:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b45:	ff 75 0c             	pushl  0xc(%ebp)
  801b48:	01 d8                	add    %ebx,%eax
  801b4a:	50                   	push   %eax
  801b4b:	e8 c5 ff ff ff       	call   801b15 <strcpy>
	return dst;
}
  801b50:	89 d8                	mov    %ebx,%eax
  801b52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b62:	89 f3                	mov    %esi,%ebx
  801b64:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b67:	89 f2                	mov    %esi,%edx
  801b69:	eb 0f                	jmp    801b7a <strncpy+0x23>
		*dst++ = *src;
  801b6b:	83 c2 01             	add    $0x1,%edx
  801b6e:	0f b6 01             	movzbl (%ecx),%eax
  801b71:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b74:	80 39 01             	cmpb   $0x1,(%ecx)
  801b77:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b7a:	39 da                	cmp    %ebx,%edx
  801b7c:	75 ed                	jne    801b6b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b7e:	89 f0                	mov    %esi,%eax
  801b80:	5b                   	pop    %ebx
  801b81:	5e                   	pop    %esi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	56                   	push   %esi
  801b88:	53                   	push   %ebx
  801b89:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8f:	8b 55 10             	mov    0x10(%ebp),%edx
  801b92:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b94:	85 d2                	test   %edx,%edx
  801b96:	74 21                	je     801bb9 <strlcpy+0x35>
  801b98:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801b9c:	89 f2                	mov    %esi,%edx
  801b9e:	eb 09                	jmp    801ba9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ba0:	83 c2 01             	add    $0x1,%edx
  801ba3:	83 c1 01             	add    $0x1,%ecx
  801ba6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ba9:	39 c2                	cmp    %eax,%edx
  801bab:	74 09                	je     801bb6 <strlcpy+0x32>
  801bad:	0f b6 19             	movzbl (%ecx),%ebx
  801bb0:	84 db                	test   %bl,%bl
  801bb2:	75 ec                	jne    801ba0 <strlcpy+0x1c>
  801bb4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bb6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bb9:	29 f0                	sub    %esi,%eax
}
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bc8:	eb 06                	jmp    801bd0 <strcmp+0x11>
		p++, q++;
  801bca:	83 c1 01             	add    $0x1,%ecx
  801bcd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bd0:	0f b6 01             	movzbl (%ecx),%eax
  801bd3:	84 c0                	test   %al,%al
  801bd5:	74 04                	je     801bdb <strcmp+0x1c>
  801bd7:	3a 02                	cmp    (%edx),%al
  801bd9:	74 ef                	je     801bca <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801bdb:	0f b6 c0             	movzbl %al,%eax
  801bde:	0f b6 12             	movzbl (%edx),%edx
  801be1:	29 d0                	sub    %edx,%eax
}
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	53                   	push   %ebx
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bef:	89 c3                	mov    %eax,%ebx
  801bf1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801bf4:	eb 06                	jmp    801bfc <strncmp+0x17>
		n--, p++, q++;
  801bf6:	83 c0 01             	add    $0x1,%eax
  801bf9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bfc:	39 d8                	cmp    %ebx,%eax
  801bfe:	74 15                	je     801c15 <strncmp+0x30>
  801c00:	0f b6 08             	movzbl (%eax),%ecx
  801c03:	84 c9                	test   %cl,%cl
  801c05:	74 04                	je     801c0b <strncmp+0x26>
  801c07:	3a 0a                	cmp    (%edx),%cl
  801c09:	74 eb                	je     801bf6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0b:	0f b6 00             	movzbl (%eax),%eax
  801c0e:	0f b6 12             	movzbl (%edx),%edx
  801c11:	29 d0                	sub    %edx,%eax
  801c13:	eb 05                	jmp    801c1a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c1a:	5b                   	pop    %ebx
  801c1b:	5d                   	pop    %ebp
  801c1c:	c3                   	ret    

00801c1d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	8b 45 08             	mov    0x8(%ebp),%eax
  801c23:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c27:	eb 07                	jmp    801c30 <strchr+0x13>
		if (*s == c)
  801c29:	38 ca                	cmp    %cl,%dl
  801c2b:	74 0f                	je     801c3c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c2d:	83 c0 01             	add    $0x1,%eax
  801c30:	0f b6 10             	movzbl (%eax),%edx
  801c33:	84 d2                	test   %dl,%dl
  801c35:	75 f2                	jne    801c29 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c48:	eb 03                	jmp    801c4d <strfind+0xf>
  801c4a:	83 c0 01             	add    $0x1,%eax
  801c4d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c50:	38 ca                	cmp    %cl,%dl
  801c52:	74 04                	je     801c58 <strfind+0x1a>
  801c54:	84 d2                	test   %dl,%dl
  801c56:	75 f2                	jne    801c4a <strfind+0xc>
			break;
	return (char *) s;
}
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	57                   	push   %edi
  801c5e:	56                   	push   %esi
  801c5f:	53                   	push   %ebx
  801c60:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c63:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c66:	85 c9                	test   %ecx,%ecx
  801c68:	74 36                	je     801ca0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c6a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c70:	75 28                	jne    801c9a <memset+0x40>
  801c72:	f6 c1 03             	test   $0x3,%cl
  801c75:	75 23                	jne    801c9a <memset+0x40>
		c &= 0xFF;
  801c77:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c7b:	89 d3                	mov    %edx,%ebx
  801c7d:	c1 e3 08             	shl    $0x8,%ebx
  801c80:	89 d6                	mov    %edx,%esi
  801c82:	c1 e6 18             	shl    $0x18,%esi
  801c85:	89 d0                	mov    %edx,%eax
  801c87:	c1 e0 10             	shl    $0x10,%eax
  801c8a:	09 f0                	or     %esi,%eax
  801c8c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801c8e:	89 d8                	mov    %ebx,%eax
  801c90:	09 d0                	or     %edx,%eax
  801c92:	c1 e9 02             	shr    $0x2,%ecx
  801c95:	fc                   	cld    
  801c96:	f3 ab                	rep stos %eax,%es:(%edi)
  801c98:	eb 06                	jmp    801ca0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9d:	fc                   	cld    
  801c9e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ca0:	89 f8                	mov    %edi,%eax
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	57                   	push   %edi
  801cab:	56                   	push   %esi
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cb2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cb5:	39 c6                	cmp    %eax,%esi
  801cb7:	73 35                	jae    801cee <memmove+0x47>
  801cb9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cbc:	39 d0                	cmp    %edx,%eax
  801cbe:	73 2e                	jae    801cee <memmove+0x47>
		s += n;
		d += n;
  801cc0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cc3:	89 d6                	mov    %edx,%esi
  801cc5:	09 fe                	or     %edi,%esi
  801cc7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ccd:	75 13                	jne    801ce2 <memmove+0x3b>
  801ccf:	f6 c1 03             	test   $0x3,%cl
  801cd2:	75 0e                	jne    801ce2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cd4:	83 ef 04             	sub    $0x4,%edi
  801cd7:	8d 72 fc             	lea    -0x4(%edx),%esi
  801cda:	c1 e9 02             	shr    $0x2,%ecx
  801cdd:	fd                   	std    
  801cde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ce0:	eb 09                	jmp    801ceb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801ce2:	83 ef 01             	sub    $0x1,%edi
  801ce5:	8d 72 ff             	lea    -0x1(%edx),%esi
  801ce8:	fd                   	std    
  801ce9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ceb:	fc                   	cld    
  801cec:	eb 1d                	jmp    801d0b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cee:	89 f2                	mov    %esi,%edx
  801cf0:	09 c2                	or     %eax,%edx
  801cf2:	f6 c2 03             	test   $0x3,%dl
  801cf5:	75 0f                	jne    801d06 <memmove+0x5f>
  801cf7:	f6 c1 03             	test   $0x3,%cl
  801cfa:	75 0a                	jne    801d06 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801cfc:	c1 e9 02             	shr    $0x2,%ecx
  801cff:	89 c7                	mov    %eax,%edi
  801d01:	fc                   	cld    
  801d02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d04:	eb 05                	jmp    801d0b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d06:	89 c7                	mov    %eax,%edi
  801d08:	fc                   	cld    
  801d09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d0b:	5e                   	pop    %esi
  801d0c:	5f                   	pop    %edi
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d12:	ff 75 10             	pushl  0x10(%ebp)
  801d15:	ff 75 0c             	pushl  0xc(%ebp)
  801d18:	ff 75 08             	pushl  0x8(%ebp)
  801d1b:	e8 87 ff ff ff       	call   801ca7 <memmove>
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	56                   	push   %esi
  801d26:	53                   	push   %ebx
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2d:	89 c6                	mov    %eax,%esi
  801d2f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d32:	eb 1a                	jmp    801d4e <memcmp+0x2c>
		if (*s1 != *s2)
  801d34:	0f b6 08             	movzbl (%eax),%ecx
  801d37:	0f b6 1a             	movzbl (%edx),%ebx
  801d3a:	38 d9                	cmp    %bl,%cl
  801d3c:	74 0a                	je     801d48 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d3e:	0f b6 c1             	movzbl %cl,%eax
  801d41:	0f b6 db             	movzbl %bl,%ebx
  801d44:	29 d8                	sub    %ebx,%eax
  801d46:	eb 0f                	jmp    801d57 <memcmp+0x35>
		s1++, s2++;
  801d48:	83 c0 01             	add    $0x1,%eax
  801d4b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d4e:	39 f0                	cmp    %esi,%eax
  801d50:	75 e2                	jne    801d34 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	53                   	push   %ebx
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d62:	89 c1                	mov    %eax,%ecx
  801d64:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d67:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d6b:	eb 0a                	jmp    801d77 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d6d:	0f b6 10             	movzbl (%eax),%edx
  801d70:	39 da                	cmp    %ebx,%edx
  801d72:	74 07                	je     801d7b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d74:	83 c0 01             	add    $0x1,%eax
  801d77:	39 c8                	cmp    %ecx,%eax
  801d79:	72 f2                	jb     801d6d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d7b:	5b                   	pop    %ebx
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d8a:	eb 03                	jmp    801d8f <strtol+0x11>
		s++;
  801d8c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d8f:	0f b6 01             	movzbl (%ecx),%eax
  801d92:	3c 20                	cmp    $0x20,%al
  801d94:	74 f6                	je     801d8c <strtol+0xe>
  801d96:	3c 09                	cmp    $0x9,%al
  801d98:	74 f2                	je     801d8c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d9a:	3c 2b                	cmp    $0x2b,%al
  801d9c:	75 0a                	jne    801da8 <strtol+0x2a>
		s++;
  801d9e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801da1:	bf 00 00 00 00       	mov    $0x0,%edi
  801da6:	eb 11                	jmp    801db9 <strtol+0x3b>
  801da8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dad:	3c 2d                	cmp    $0x2d,%al
  801daf:	75 08                	jne    801db9 <strtol+0x3b>
		s++, neg = 1;
  801db1:	83 c1 01             	add    $0x1,%ecx
  801db4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801db9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dbf:	75 15                	jne    801dd6 <strtol+0x58>
  801dc1:	80 39 30             	cmpb   $0x30,(%ecx)
  801dc4:	75 10                	jne    801dd6 <strtol+0x58>
  801dc6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dca:	75 7c                	jne    801e48 <strtol+0xca>
		s += 2, base = 16;
  801dcc:	83 c1 02             	add    $0x2,%ecx
  801dcf:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dd4:	eb 16                	jmp    801dec <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801dd6:	85 db                	test   %ebx,%ebx
  801dd8:	75 12                	jne    801dec <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801dda:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ddf:	80 39 30             	cmpb   $0x30,(%ecx)
  801de2:	75 08                	jne    801dec <strtol+0x6e>
		s++, base = 8;
  801de4:	83 c1 01             	add    $0x1,%ecx
  801de7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
  801df1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801df4:	0f b6 11             	movzbl (%ecx),%edx
  801df7:	8d 72 d0             	lea    -0x30(%edx),%esi
  801dfa:	89 f3                	mov    %esi,%ebx
  801dfc:	80 fb 09             	cmp    $0x9,%bl
  801dff:	77 08                	ja     801e09 <strtol+0x8b>
			dig = *s - '0';
  801e01:	0f be d2             	movsbl %dl,%edx
  801e04:	83 ea 30             	sub    $0x30,%edx
  801e07:	eb 22                	jmp    801e2b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e09:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e0c:	89 f3                	mov    %esi,%ebx
  801e0e:	80 fb 19             	cmp    $0x19,%bl
  801e11:	77 08                	ja     801e1b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e13:	0f be d2             	movsbl %dl,%edx
  801e16:	83 ea 57             	sub    $0x57,%edx
  801e19:	eb 10                	jmp    801e2b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e1e:	89 f3                	mov    %esi,%ebx
  801e20:	80 fb 19             	cmp    $0x19,%bl
  801e23:	77 16                	ja     801e3b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e25:	0f be d2             	movsbl %dl,%edx
  801e28:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e2e:	7d 0b                	jge    801e3b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e30:	83 c1 01             	add    $0x1,%ecx
  801e33:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e37:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e39:	eb b9                	jmp    801df4 <strtol+0x76>

	if (endptr)
  801e3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e3f:	74 0d                	je     801e4e <strtol+0xd0>
		*endptr = (char *) s;
  801e41:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e44:	89 0e                	mov    %ecx,(%esi)
  801e46:	eb 06                	jmp    801e4e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e48:	85 db                	test   %ebx,%ebx
  801e4a:	74 98                	je     801de4 <strtol+0x66>
  801e4c:	eb 9e                	jmp    801dec <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e4e:	89 c2                	mov    %eax,%edx
  801e50:	f7 da                	neg    %edx
  801e52:	85 ff                	test   %edi,%edi
  801e54:	0f 45 c2             	cmovne %edx,%eax
}
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5f                   	pop    %edi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    

00801e5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	8b 75 08             	mov    0x8(%ebp),%esi
  801e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e6a:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e6c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e71:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e74:	83 ec 0c             	sub    $0xc,%esp
  801e77:	50                   	push   %eax
  801e78:	e8 96 e4 ff ff       	call   800313 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	85 f6                	test   %esi,%esi
  801e82:	74 14                	je     801e98 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e84:	ba 00 00 00 00       	mov    $0x0,%edx
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	78 09                	js     801e96 <ipc_recv+0x3a>
  801e8d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e93:	8b 52 74             	mov    0x74(%edx),%edx
  801e96:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e98:	85 db                	test   %ebx,%ebx
  801e9a:	74 14                	je     801eb0 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801e9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 09                	js     801eae <ipc_recv+0x52>
  801ea5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eab:	8b 52 78             	mov    0x78(%edx),%edx
  801eae:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 08                	js     801ebc <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801eb4:	a1 08 40 80 00       	mov    0x804008,%eax
  801eb9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	57                   	push   %edi
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ecf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ed5:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ed7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801edc:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801edf:	ff 75 14             	pushl  0x14(%ebp)
  801ee2:	53                   	push   %ebx
  801ee3:	56                   	push   %esi
  801ee4:	57                   	push   %edi
  801ee5:	e8 06 e4 ff ff       	call   8002f0 <sys_ipc_try_send>

		if (err < 0) {
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	85 c0                	test   %eax,%eax
  801eef:	79 1e                	jns    801f0f <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ef1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef4:	75 07                	jne    801efd <ipc_send+0x3a>
				sys_yield();
  801ef6:	e8 49 e2 ff ff       	call   800144 <sys_yield>
  801efb:	eb e2                	jmp    801edf <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801efd:	50                   	push   %eax
  801efe:	68 a0 26 80 00       	push   $0x8026a0
  801f03:	6a 49                	push   $0x49
  801f05:	68 ad 26 80 00       	push   $0x8026ad
  801f0a:	e8 a8 f5 ff ff       	call   8014b7 <_panic>
		}

	} while (err < 0);

}
  801f0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f12:	5b                   	pop    %ebx
  801f13:	5e                   	pop    %esi
  801f14:	5f                   	pop    %edi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    

00801f17 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f1d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f22:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f25:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f2b:	8b 52 50             	mov    0x50(%edx),%edx
  801f2e:	39 ca                	cmp    %ecx,%edx
  801f30:	75 0d                	jne    801f3f <ipc_find_env+0x28>
			return envs[i].env_id;
  801f32:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f35:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f3a:	8b 40 48             	mov    0x48(%eax),%eax
  801f3d:	eb 0f                	jmp    801f4e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f3f:	83 c0 01             	add    $0x1,%eax
  801f42:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f47:	75 d9                	jne    801f22 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f56:	89 d0                	mov    %edx,%eax
  801f58:	c1 e8 16             	shr    $0x16,%eax
  801f5b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f67:	f6 c1 01             	test   $0x1,%cl
  801f6a:	74 1d                	je     801f89 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6c:	c1 ea 0c             	shr    $0xc,%edx
  801f6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f76:	f6 c2 01             	test   $0x1,%dl
  801f79:	74 0e                	je     801f89 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7b:	c1 ea 0c             	shr    $0xc,%edx
  801f7e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f85:	ef 
  801f86:	0f b7 c0             	movzwl %ax,%eax
}
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    
  801f8b:	66 90                	xchg   %ax,%ax
  801f8d:	66 90                	xchg   %ax,%ax
  801f8f:	90                   	nop

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
