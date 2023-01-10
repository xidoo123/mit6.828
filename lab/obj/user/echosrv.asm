
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 91 04 00 00       	call   8004c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 30 27 80 00       	push   $0x802730
  80003f:	e8 71 05 00 00       	call   8005b5 <cprintf>
	exit();
  800044:	e8 bf 04 00 00       	call   800508 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:

void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 30             	sub    $0x30,%esp
  800057:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005a:	6a 20                	push   $0x20
  80005c:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	56                   	push   %esi
  800061:	e8 05 14 00 00       	call   80146b <read>
  800066:	89 c3                	mov    %eax,%ebx
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	79 0a                	jns    800079 <handle_client+0x2b>
		die("Failed to receive initial bytes from client");
  80006f:	b8 34 27 80 00       	mov    $0x802734,%eax
  800074:	e8 ba ff ff ff       	call   800033 <die>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  800079:	8d 7d c8             	lea    -0x38(%ebp),%edi
  80007c:	eb 3b                	jmp    8000b9 <handle_client+0x6b>
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	53                   	push   %ebx
  800082:	57                   	push   %edi
  800083:	56                   	push   %esi
  800084:	e8 bc 14 00 00       	call   801545 <write>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	39 c3                	cmp    %eax,%ebx
  80008e:	74 0a                	je     80009a <handle_client+0x4c>
			die("Failed to send bytes to client");
  800090:	b8 60 27 80 00       	mov    $0x802760,%eax
  800095:	e8 99 ff ff ff       	call   800033 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	6a 20                	push   $0x20
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	e8 c5 13 00 00       	call   80146b <read>
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 0a                	jns    8000b9 <handle_client+0x6b>
			die("Failed to receive additional bytes from client");
  8000af:	b8 80 27 80 00       	mov    $0x802780,%eax
  8000b4:	e8 7a ff ff ff       	call   800033 <die>
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000b9:	85 db                	test   %ebx,%ebx
  8000bb:	7f c1                	jg     80007e <handle_client+0x30>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	56                   	push   %esi
  8000c1:	e8 69 12 00 00       	call   80132f <close>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <umain>:

void
umain(int argc, char **argv)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 40             	sub    $0x40,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000da:	6a 06                	push   $0x6
  8000dc:	6a 01                	push   $0x1
  8000de:	6a 02                	push   $0x2
  8000e0:	e8 97 1a 00 00       	call   801b7c <socket>
  8000e5:	89 c6                	mov    %eax,%esi
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	79 0a                	jns    8000f8 <umain+0x27>
		die("Failed to create socket");
  8000ee:	b8 e0 26 80 00       	mov    $0x8026e0,%eax
  8000f3:	e8 3b ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	68 f8 26 80 00       	push   $0x8026f8
  800100:	e8 b0 04 00 00       	call   8005b5 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800105:	83 c4 0c             	add    $0xc,%esp
  800108:	6a 10                	push   $0x10
  80010a:	6a 00                	push   $0x0
  80010c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80010f:	53                   	push   %ebx
  800110:	e8 6a 0b 00 00       	call   800c7f <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  800115:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800120:	e8 6c 01 00 00       	call   800291 <htonl>
  800125:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800128:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80012f:	e8 43 01 00 00       	call   800277 <htons>
  800134:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800138:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  80013f:	e8 71 04 00 00       	call   8005b5 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  800144:	83 c4 0c             	add    $0xc,%esp
  800147:	6a 10                	push   $0x10
  800149:	53                   	push   %ebx
  80014a:	56                   	push   %esi
  80014b:	e8 9a 19 00 00       	call   801aea <bind>
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	85 c0                	test   %eax,%eax
  800155:	79 0a                	jns    800161 <umain+0x90>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800157:	b8 b0 27 80 00       	mov    $0x8027b0,%eax
  80015c:	e8 d2 fe ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	6a 05                	push   $0x5
  800166:	56                   	push   %esi
  800167:	e8 ed 19 00 00       	call   801b59 <listen>
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	85 c0                	test   %eax,%eax
  800171:	79 0a                	jns    80017d <umain+0xac>
		die("Failed to listen on server socket");
  800173:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
  800178:	e8 b6 fe ff ff       	call   800033 <die>

	cprintf("bound\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 17 27 80 00       	push   $0x802717
  800185:	e8 2b 04 00 00       	call   8005b5 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  80018d:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  800190:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	57                   	push   %edi
  80019b:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	56                   	push   %esi
  8001a0:	e8 0e 19 00 00       	call   801ab3 <accept>
  8001a5:	89 c3                	mov    %eax,%ebx
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	79 0a                	jns    8001b8 <umain+0xe7>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001ae:	b8 f8 27 80 00       	mov    $0x8027f8,%eax
  8001b3:	e8 7b fe ff ff       	call   800033 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	ff 75 cc             	pushl  -0x34(%ebp)
  8001be:	e8 1b 00 00 00       	call   8001de <inet_ntoa>
  8001c3:	83 c4 08             	add    $0x8,%esp
  8001c6:	50                   	push   %eax
  8001c7:	68 1e 27 80 00       	push   $0x80271e
  8001cc:	e8 e4 03 00 00       	call   8005b5 <cprintf>
		handle_client(clientsock);
  8001d1:	89 1c 24             	mov    %ebx,(%esp)
  8001d4:	e8 75 fe ff ff       	call   80004e <handle_client>
	}
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb b2                	jmp    800190 <umain+0xbf>

008001de <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	57                   	push   %edi
  8001e2:	56                   	push   %esi
  8001e3:	53                   	push   %ebx
  8001e4:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001f0:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001f7:	0f b6 0f             	movzbl (%edi),%ecx
  8001fa:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001ff:	0f b6 d9             	movzbl %cl,%ebx
  800202:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800205:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800208:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80020b:	66 c1 e8 0b          	shr    $0xb,%ax
  80020f:	89 c3                	mov    %eax,%ebx
  800211:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800214:	01 c0                	add    %eax,%eax
  800216:	29 c1                	sub    %eax,%ecx
  800218:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  80021a:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80021c:	8d 72 01             	lea    0x1(%edx),%esi
  80021f:	0f b6 d2             	movzbl %dl,%edx
  800222:	83 c0 30             	add    $0x30,%eax
  800225:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800229:	89 f2                	mov    %esi,%edx
    } while(*ap);
  80022b:	84 db                	test   %bl,%bl
  80022d:	75 d0                	jne    8001ff <inet_ntoa+0x21>
  80022f:	c6 07 00             	movb   $0x0,(%edi)
  800232:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800235:	eb 0d                	jmp    800244 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800237:	0f b6 c2             	movzbl %dl,%eax
  80023a:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  80023f:	88 01                	mov    %al,(%ecx)
  800241:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800244:	83 ea 01             	sub    $0x1,%edx
  800247:	80 fa ff             	cmp    $0xff,%dl
  80024a:	75 eb                	jne    800237 <inet_ntoa+0x59>
  80024c:	89 f0                	mov    %esi,%eax
  80024e:	0f b6 f0             	movzbl %al,%esi
  800251:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  800254:	8d 46 01             	lea    0x1(%esi),%eax
  800257:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025a:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  80025d:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800263:	39 c7                	cmp    %eax,%edi
  800265:	75 90                	jne    8001f7 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800267:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  80026a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80027a:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80027e:	66 c1 c0 08          	rol    $0x8,%ax
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800287:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80028b:	66 c1 c0 08          	rol    $0x8,%ax
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800297:	89 d1                	mov    %edx,%ecx
  800299:	c1 e1 18             	shl    $0x18,%ecx
  80029c:	89 d0                	mov    %edx,%eax
  80029e:	c1 e8 18             	shr    $0x18,%eax
  8002a1:	09 c8                	or     %ecx,%eax
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002ab:	c1 e1 08             	shl    $0x8,%ecx
  8002ae:	09 c8                	or     %ecx,%eax
  8002b0:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002b6:	c1 ea 08             	shr    $0x8,%edx
  8002b9:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 20             	sub    $0x20,%esp
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002c9:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002cc:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002cf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002d2:	0f b6 ca             	movzbl %dl,%ecx
  8002d5:	83 e9 30             	sub    $0x30,%ecx
  8002d8:	83 f9 09             	cmp    $0x9,%ecx
  8002db:	0f 87 94 01 00 00    	ja     800475 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002e1:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002e8:	83 fa 30             	cmp    $0x30,%edx
  8002eb:	75 2b                	jne    800318 <inet_aton+0x5b>
      c = *++cp;
  8002ed:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002f1:	89 d1                	mov    %edx,%ecx
  8002f3:	83 e1 df             	and    $0xffffffdf,%ecx
  8002f6:	80 f9 58             	cmp    $0x58,%cl
  8002f9:	74 0f                	je     80030a <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002fb:	83 c0 01             	add    $0x1,%eax
  8002fe:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800301:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800308:	eb 0e                	jmp    800318 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80030a:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80030e:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800311:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800318:	83 c0 01             	add    $0x1,%eax
  80031b:	be 00 00 00 00       	mov    $0x0,%esi
  800320:	eb 03                	jmp    800325 <inet_aton+0x68>
  800322:	83 c0 01             	add    $0x1,%eax
  800325:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800328:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80032b:	0f b6 fa             	movzbl %dl,%edi
  80032e:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800331:	83 f9 09             	cmp    $0x9,%ecx
  800334:	77 0d                	ja     800343 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800336:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  80033a:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  80033e:	0f be 10             	movsbl (%eax),%edx
  800341:	eb df                	jmp    800322 <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  800343:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800347:	75 32                	jne    80037b <inet_aton+0xbe>
  800349:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  80034c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80034f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800352:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800358:	83 e9 41             	sub    $0x41,%ecx
  80035b:	83 f9 05             	cmp    $0x5,%ecx
  80035e:	77 1b                	ja     80037b <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800360:	c1 e6 04             	shl    $0x4,%esi
  800363:	83 c2 0a             	add    $0xa,%edx
  800366:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  80036a:	19 c9                	sbb    %ecx,%ecx
  80036c:	83 e1 20             	and    $0x20,%ecx
  80036f:	83 c1 41             	add    $0x41,%ecx
  800372:	29 ca                	sub    %ecx,%edx
  800374:	09 d6                	or     %edx,%esi
        c = *++cp;
  800376:	0f be 10             	movsbl (%eax),%edx
  800379:	eb a7                	jmp    800322 <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  80037b:	83 fa 2e             	cmp    $0x2e,%edx
  80037e:	75 23                	jne    8003a3 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800380:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800383:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800386:	39 f8                	cmp    %edi,%eax
  800388:	0f 84 ee 00 00 00    	je     80047c <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  80038e:	83 c0 04             	add    $0x4,%eax
  800391:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800394:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800397:	8d 43 01             	lea    0x1(%ebx),%eax
  80039a:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  80039e:	e9 2f ff ff ff       	jmp    8002d2 <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003a3:	85 d2                	test   %edx,%edx
  8003a5:	74 25                	je     8003cc <inet_aton+0x10f>
  8003a7:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003af:	83 f9 5f             	cmp    $0x5f,%ecx
  8003b2:	0f 87 d0 00 00 00    	ja     800488 <inet_aton+0x1cb>
  8003b8:	83 fa 20             	cmp    $0x20,%edx
  8003bb:	74 0f                	je     8003cc <inet_aton+0x10f>
  8003bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c0:	83 ea 09             	sub    $0x9,%edx
  8003c3:	83 fa 04             	cmp    $0x4,%edx
  8003c6:	0f 87 bc 00 00 00    	ja     800488 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003d2:	29 c2                	sub    %eax,%edx
  8003d4:	c1 fa 02             	sar    $0x2,%edx
  8003d7:	83 c2 01             	add    $0x1,%edx
  8003da:	83 fa 02             	cmp    $0x2,%edx
  8003dd:	74 20                	je     8003ff <inet_aton+0x142>
  8003df:	83 fa 02             	cmp    $0x2,%edx
  8003e2:	7f 0f                	jg     8003f3 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	0f 84 97 00 00 00    	je     800488 <inet_aton+0x1cb>
  8003f1:	eb 67                	jmp    80045a <inet_aton+0x19d>
  8003f3:	83 fa 03             	cmp    $0x3,%edx
  8003f6:	74 1e                	je     800416 <inet_aton+0x159>
  8003f8:	83 fa 04             	cmp    $0x4,%edx
  8003fb:	74 38                	je     800435 <inet_aton+0x178>
  8003fd:	eb 5b                	jmp    80045a <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800404:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  80040a:	77 7c                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  80040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040f:	c1 e0 18             	shl    $0x18,%eax
  800412:	09 c6                	or     %eax,%esi
    break;
  800414:	eb 44                	jmp    80045a <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80041b:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800421:	77 65                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800426:	c1 e2 18             	shl    $0x18,%edx
  800429:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80042c:	c1 e0 10             	shl    $0x10,%eax
  80042f:	09 d0                	or     %edx,%eax
  800431:	09 c6                	or     %eax,%esi
    break;
  800433:	eb 25                	jmp    80045a <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80043a:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800440:	77 46                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800445:	c1 e2 18             	shl    $0x18,%edx
  800448:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80044b:	c1 e0 10             	shl    $0x10,%eax
  80044e:	09 c2                	or     %eax,%edx
  800450:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800453:	c1 e0 08             	shl    $0x8,%eax
  800456:	09 d0                	or     %edx,%eax
  800458:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  80045a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80045e:	74 23                	je     800483 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800460:	56                   	push   %esi
  800461:	e8 2b fe ff ff       	call   800291 <htonl>
  800466:	83 c4 04             	add    $0x4,%esp
  800469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80046c:	89 03                	mov    %eax,(%ebx)
  return (1);
  80046e:	b8 01 00 00 00       	mov    $0x1,%eax
  800473:	eb 13                	jmp    800488 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	eb 0c                	jmp    800488 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	eb 05                	jmp    800488 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800483:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800496:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800499:	50                   	push   %eax
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	e8 1b fe ff ff       	call   8002bd <inet_aton>
  8004a2:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004ac:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	e8 d4 fd ff ff       	call   800291 <htonl>
  8004bd:	83 c4 04             	add    $0x4,%esp
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	56                   	push   %esi
  8004c6:	53                   	push   %ebx
  8004c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8004cd:	e8 2d 0a 00 00       	call   800eff <sys_getenvid>
  8004d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004df:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7e 07                	jle    8004ef <libmain+0x2d>
		binaryname = argv[0];
  8004e8:	8b 06                	mov    (%esi),%eax
  8004ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	e8 d8 fb ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  8004f9:	e8 0a 00 00 00       	call   800508 <exit>
}
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80050e:	e8 47 0e 00 00       	call   80135a <close_all>
	sys_env_destroy(0);
  800513:	83 ec 0c             	sub    $0xc,%esp
  800516:	6a 00                	push   $0x0
  800518:	e8 a1 09 00 00       	call   800ebe <sys_env_destroy>
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80052c:	8b 13                	mov    (%ebx),%edx
  80052e:	8d 42 01             	lea    0x1(%edx),%eax
  800531:	89 03                	mov    %eax,(%ebx)
  800533:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800536:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80053a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80053f:	75 1a                	jne    80055b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	68 ff 00 00 00       	push   $0xff
  800549:	8d 43 08             	lea    0x8(%ebx),%eax
  80054c:	50                   	push   %eax
  80054d:	e8 2f 09 00 00       	call   800e81 <sys_cputs>
		b->idx = 0;
  800552:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800558:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80055b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80055f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80056d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800574:	00 00 00 
	b.cnt = 0;
  800577:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80057e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	ff 75 08             	pushl  0x8(%ebp)
  800587:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	68 22 05 80 00       	push   $0x800522
  800593:	e8 54 01 00 00       	call   8006ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005a7:	50                   	push   %eax
  8005a8:	e8 d4 08 00 00       	call   800e81 <sys_cputs>

	return b.cnt;
}
  8005ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005be:	50                   	push   %eax
  8005bf:	ff 75 08             	pushl  0x8(%ebp)
  8005c2:	e8 9d ff ff ff       	call   800564 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005c7:	c9                   	leave  
  8005c8:	c3                   	ret    

008005c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	57                   	push   %edi
  8005cd:	56                   	push   %esi
  8005ce:	53                   	push   %ebx
  8005cf:	83 ec 1c             	sub    $0x1c,%esp
  8005d2:	89 c7                	mov    %eax,%edi
  8005d4:	89 d6                	mov    %edx,%esi
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005df:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f0:	39 d3                	cmp    %edx,%ebx
  8005f2:	72 05                	jb     8005f9 <printnum+0x30>
  8005f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005f7:	77 45                	ja     80063e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	ff 75 18             	pushl  0x18(%ebp)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800605:	53                   	push   %ebx
  800606:	ff 75 10             	pushl  0x10(%ebp)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff 75 dc             	pushl  -0x24(%ebp)
  800615:	ff 75 d8             	pushl  -0x28(%ebp)
  800618:	e8 33 1e 00 00       	call   802450 <__udivdi3>
  80061d:	83 c4 18             	add    $0x18,%esp
  800620:	52                   	push   %edx
  800621:	50                   	push   %eax
  800622:	89 f2                	mov    %esi,%edx
  800624:	89 f8                	mov    %edi,%eax
  800626:	e8 9e ff ff ff       	call   8005c9 <printnum>
  80062b:	83 c4 20             	add    $0x20,%esp
  80062e:	eb 18                	jmp    800648 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	ff 75 18             	pushl  0x18(%ebp)
  800637:	ff d7                	call   *%edi
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb 03                	jmp    800641 <printnum+0x78>
  80063e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f e8                	jg     800630 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	56                   	push   %esi
  80064c:	83 ec 04             	sub    $0x4,%esp
  80064f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800652:	ff 75 e0             	pushl  -0x20(%ebp)
  800655:	ff 75 dc             	pushl  -0x24(%ebp)
  800658:	ff 75 d8             	pushl  -0x28(%ebp)
  80065b:	e8 20 1f 00 00       	call   802580 <__umoddi3>
  800660:	83 c4 14             	add    $0x14,%esp
  800663:	0f be 80 25 28 80 00 	movsbl 0x802825(%eax),%eax
  80066a:	50                   	push   %eax
  80066b:	ff d7                	call   *%edi
}
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80067b:	83 fa 01             	cmp    $0x1,%edx
  80067e:	7e 0e                	jle    80068e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8d 4a 08             	lea    0x8(%edx),%ecx
  800685:	89 08                	mov    %ecx,(%eax)
  800687:	8b 02                	mov    (%edx),%eax
  800689:	8b 52 04             	mov    0x4(%edx),%edx
  80068c:	eb 22                	jmp    8006b0 <getuint+0x38>
	else if (lflag)
  80068e:	85 d2                	test   %edx,%edx
  800690:	74 10                	je     8006a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800692:	8b 10                	mov    (%eax),%edx
  800694:	8d 4a 04             	lea    0x4(%edx),%ecx
  800697:	89 08                	mov    %ecx,(%eax)
  800699:	8b 02                	mov    (%edx),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a0:	eb 0e                	jmp    8006b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a7:	89 08                	mov    %ecx,(%eax)
  8006a9:	8b 02                	mov    (%edx),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c1:	73 0a                	jae    8006cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8006c3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006c6:	89 08                	mov    %ecx,(%eax)
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	88 02                	mov    %al,(%edx)
}
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 05 00 00 00       	call   8006ec <vprintfmt>
	va_end(ap);
}
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	57                   	push   %edi
  8006f0:	56                   	push   %esi
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 2c             	sub    $0x2c,%esp
  8006f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006fe:	eb 12                	jmp    800712 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800700:	85 c0                	test   %eax,%eax
  800702:	0f 84 89 03 00 00    	je     800a91 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	50                   	push   %eax
  80070d:	ff d6                	call   *%esi
  80070f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800712:	83 c7 01             	add    $0x1,%edi
  800715:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800719:	83 f8 25             	cmp    $0x25,%eax
  80071c:	75 e2                	jne    800700 <vprintfmt+0x14>
  80071e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800722:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800729:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800730:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
  80073c:	eb 07                	jmp    800745 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800741:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8d 47 01             	lea    0x1(%edi),%eax
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074b:	0f b6 07             	movzbl (%edi),%eax
  80074e:	0f b6 c8             	movzbl %al,%ecx
  800751:	83 e8 23             	sub    $0x23,%eax
  800754:	3c 55                	cmp    $0x55,%al
  800756:	0f 87 1a 03 00 00    	ja     800a76 <vprintfmt+0x38a>
  80075c:	0f b6 c0             	movzbl %al,%eax
  80075f:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  800766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800769:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80076d:	eb d6                	jmp    800745 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80077d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800781:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800784:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800787:	83 fa 09             	cmp    $0x9,%edx
  80078a:	77 39                	ja     8007c5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80078c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078f:	eb e9                	jmp    80077a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 48 04             	lea    0x4(%eax),%ecx
  800797:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a2:	eb 27                	jmp    8007cb <vprintfmt+0xdf>
  8007a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	0f 49 c8             	cmovns %eax,%ecx
  8007b1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b7:	eb 8c                	jmp    800745 <vprintfmt+0x59>
  8007b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007bc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007c3:	eb 80                	jmp    800745 <vprintfmt+0x59>
  8007c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007cf:	0f 89 70 ff ff ff    	jns    800745 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007e2:	e9 5e ff ff ff       	jmp    800745 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ed:	e9 53 ff ff ff       	jmp    800745 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	ff 30                	pushl  (%eax)
  800801:	ff d6                	call   *%esi
			break;
  800803:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800806:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800809:	e9 04 ff ff ff       	jmp    800712 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8d 50 04             	lea    0x4(%eax),%edx
  800814:	89 55 14             	mov    %edx,0x14(%ebp)
  800817:	8b 00                	mov    (%eax),%eax
  800819:	99                   	cltd   
  80081a:	31 d0                	xor    %edx,%eax
  80081c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80081e:	83 f8 0f             	cmp    $0xf,%eax
  800821:	7f 0b                	jg     80082e <vprintfmt+0x142>
  800823:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  80082a:	85 d2                	test   %edx,%edx
  80082c:	75 18                	jne    800846 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80082e:	50                   	push   %eax
  80082f:	68 3d 28 80 00       	push   $0x80283d
  800834:	53                   	push   %ebx
  800835:	56                   	push   %esi
  800836:	e8 94 fe ff ff       	call   8006cf <printfmt>
  80083b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800841:	e9 cc fe ff ff       	jmp    800712 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800846:	52                   	push   %edx
  800847:	68 f5 2b 80 00       	push   $0x802bf5
  80084c:	53                   	push   %ebx
  80084d:	56                   	push   %esi
  80084e:	e8 7c fe ff ff       	call   8006cf <printfmt>
  800853:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800859:	e9 b4 fe ff ff       	jmp    800712 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8d 50 04             	lea    0x4(%eax),%edx
  800864:	89 55 14             	mov    %edx,0x14(%ebp)
  800867:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800869:	85 ff                	test   %edi,%edi
  80086b:	b8 36 28 80 00       	mov    $0x802836,%eax
  800870:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800873:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800877:	0f 8e 94 00 00 00    	jle    800911 <vprintfmt+0x225>
  80087d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800881:	0f 84 98 00 00 00    	je     80091f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	ff 75 d0             	pushl  -0x30(%ebp)
  80088d:	57                   	push   %edi
  80088e:	e8 86 02 00 00       	call   800b19 <strnlen>
  800893:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800896:	29 c1                	sub    %eax,%ecx
  800898:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80089b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80089e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008a8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008aa:	eb 0f                	jmp    8008bb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b5:	83 ef 01             	sub    $0x1,%edi
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	85 ff                	test   %edi,%edi
  8008bd:	7f ed                	jg     8008ac <vprintfmt+0x1c0>
  8008bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008c2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cc:	0f 49 c1             	cmovns %ecx,%eax
  8008cf:	29 c1                	sub    %eax,%ecx
  8008d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8008d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008da:	89 cb                	mov    %ecx,%ebx
  8008dc:	eb 4d                	jmp    80092b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008e2:	74 1b                	je     8008ff <vprintfmt+0x213>
  8008e4:	0f be c0             	movsbl %al,%eax
  8008e7:	83 e8 20             	sub    $0x20,%eax
  8008ea:	83 f8 5e             	cmp    $0x5e,%eax
  8008ed:	76 10                	jbe    8008ff <vprintfmt+0x213>
					putch('?', putdat);
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	ff 75 0c             	pushl  0xc(%ebp)
  8008f5:	6a 3f                	push   $0x3f
  8008f7:	ff 55 08             	call   *0x8(%ebp)
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	eb 0d                	jmp    80090c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	52                   	push   %edx
  800906:	ff 55 08             	call   *0x8(%ebp)
  800909:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090c:	83 eb 01             	sub    $0x1,%ebx
  80090f:	eb 1a                	jmp    80092b <vprintfmt+0x23f>
  800911:	89 75 08             	mov    %esi,0x8(%ebp)
  800914:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800917:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80091a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80091d:	eb 0c                	jmp    80092b <vprintfmt+0x23f>
  80091f:	89 75 08             	mov    %esi,0x8(%ebp)
  800922:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800925:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800928:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80092b:	83 c7 01             	add    $0x1,%edi
  80092e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800932:	0f be d0             	movsbl %al,%edx
  800935:	85 d2                	test   %edx,%edx
  800937:	74 23                	je     80095c <vprintfmt+0x270>
  800939:	85 f6                	test   %esi,%esi
  80093b:	78 a1                	js     8008de <vprintfmt+0x1f2>
  80093d:	83 ee 01             	sub    $0x1,%esi
  800940:	79 9c                	jns    8008de <vprintfmt+0x1f2>
  800942:	89 df                	mov    %ebx,%edi
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094a:	eb 18                	jmp    800964 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80094c:	83 ec 08             	sub    $0x8,%esp
  80094f:	53                   	push   %ebx
  800950:	6a 20                	push   $0x20
  800952:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800954:	83 ef 01             	sub    $0x1,%edi
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	eb 08                	jmp    800964 <vprintfmt+0x278>
  80095c:	89 df                	mov    %ebx,%edi
  80095e:	8b 75 08             	mov    0x8(%ebp),%esi
  800961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800964:	85 ff                	test   %edi,%edi
  800966:	7f e4                	jg     80094c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800968:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096b:	e9 a2 fd ff ff       	jmp    800712 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800970:	83 fa 01             	cmp    $0x1,%edx
  800973:	7e 16                	jle    80098b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	8d 50 08             	lea    0x8(%eax),%edx
  80097b:	89 55 14             	mov    %edx,0x14(%ebp)
  80097e:	8b 50 04             	mov    0x4(%eax),%edx
  800981:	8b 00                	mov    (%eax),%eax
  800983:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800986:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800989:	eb 32                	jmp    8009bd <vprintfmt+0x2d1>
	else if (lflag)
  80098b:	85 d2                	test   %edx,%edx
  80098d:	74 18                	je     8009a7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099d:	89 c1                	mov    %eax,%ecx
  80099f:	c1 f9 1f             	sar    $0x1f,%ecx
  8009a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009a5:	eb 16                	jmp    8009bd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8d 50 04             	lea    0x4(%eax),%edx
  8009ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b0:	8b 00                	mov    (%eax),%eax
  8009b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b5:	89 c1                	mov    %eax,%ecx
  8009b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009cc:	79 74                	jns    800a42 <vprintfmt+0x356>
				putch('-', putdat);
  8009ce:	83 ec 08             	sub    $0x8,%esp
  8009d1:	53                   	push   %ebx
  8009d2:	6a 2d                	push   $0x2d
  8009d4:	ff d6                	call   *%esi
				num = -(long long) num;
  8009d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009dc:	f7 d8                	neg    %eax
  8009de:	83 d2 00             	adc    $0x0,%edx
  8009e1:	f7 da                	neg    %edx
  8009e3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009eb:	eb 55                	jmp    800a42 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f0:	e8 83 fc ff ff       	call   800678 <getuint>
			base = 10;
  8009f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009fa:	eb 46                	jmp    800a42 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8009fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ff:	e8 74 fc ff ff       	call   800678 <getuint>
			base = 8;
  800a04:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a09:	eb 37                	jmp    800a42 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a0b:	83 ec 08             	sub    $0x8,%esp
  800a0e:	53                   	push   %ebx
  800a0f:	6a 30                	push   $0x30
  800a11:	ff d6                	call   *%esi
			putch('x', putdat);
  800a13:	83 c4 08             	add    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 78                	push   $0x78
  800a19:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1e:	8d 50 04             	lea    0x4(%eax),%edx
  800a21:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a24:	8b 00                	mov    (%eax),%eax
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a2b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a2e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a33:	eb 0d                	jmp    800a42 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a35:	8d 45 14             	lea    0x14(%ebp),%eax
  800a38:	e8 3b fc ff ff       	call   800678 <getuint>
			base = 16;
  800a3d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a42:	83 ec 0c             	sub    $0xc,%esp
  800a45:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a49:	57                   	push   %edi
  800a4a:	ff 75 e0             	pushl  -0x20(%ebp)
  800a4d:	51                   	push   %ecx
  800a4e:	52                   	push   %edx
  800a4f:	50                   	push   %eax
  800a50:	89 da                	mov    %ebx,%edx
  800a52:	89 f0                	mov    %esi,%eax
  800a54:	e8 70 fb ff ff       	call   8005c9 <printnum>
			break;
  800a59:	83 c4 20             	add    $0x20,%esp
  800a5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5f:	e9 ae fc ff ff       	jmp    800712 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	53                   	push   %ebx
  800a68:	51                   	push   %ecx
  800a69:	ff d6                	call   *%esi
			break;
  800a6b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a71:	e9 9c fc ff ff       	jmp    800712 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a76:	83 ec 08             	sub    $0x8,%esp
  800a79:	53                   	push   %ebx
  800a7a:	6a 25                	push   $0x25
  800a7c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a7e:	83 c4 10             	add    $0x10,%esp
  800a81:	eb 03                	jmp    800a86 <vprintfmt+0x39a>
  800a83:	83 ef 01             	sub    $0x1,%edi
  800a86:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a8a:	75 f7                	jne    800a83 <vprintfmt+0x397>
  800a8c:	e9 81 fc ff ff       	jmp    800712 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 18             	sub    $0x18,%esp
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aa8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aaf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ab6:	85 c0                	test   %eax,%eax
  800ab8:	74 26                	je     800ae0 <vsnprintf+0x47>
  800aba:	85 d2                	test   %edx,%edx
  800abc:	7e 22                	jle    800ae0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800abe:	ff 75 14             	pushl  0x14(%ebp)
  800ac1:	ff 75 10             	pushl  0x10(%ebp)
  800ac4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac7:	50                   	push   %eax
  800ac8:	68 b2 06 80 00       	push   $0x8006b2
  800acd:	e8 1a fc ff ff       	call   8006ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	eb 05                	jmp    800ae5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af0:	50                   	push   %eax
  800af1:	ff 75 10             	pushl  0x10(%ebp)
  800af4:	ff 75 0c             	pushl  0xc(%ebp)
  800af7:	ff 75 08             	pushl  0x8(%ebp)
  800afa:	e8 9a ff ff ff       	call   800a99 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    

00800b01 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	eb 03                	jmp    800b11 <strlen+0x10>
		n++;
  800b0e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b11:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b15:	75 f7                	jne    800b0e <strlen+0xd>
		n++;
	return n;
}
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	eb 03                	jmp    800b2c <strnlen+0x13>
		n++;
  800b29:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2c:	39 c2                	cmp    %eax,%edx
  800b2e:	74 08                	je     800b38 <strnlen+0x1f>
  800b30:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b34:	75 f3                	jne    800b29 <strnlen+0x10>
  800b36:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	53                   	push   %ebx
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b44:	89 c2                	mov    %eax,%edx
  800b46:	83 c2 01             	add    $0x1,%edx
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b50:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b53:	84 db                	test   %bl,%bl
  800b55:	75 ef                	jne    800b46 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b57:	5b                   	pop    %ebx
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b61:	53                   	push   %ebx
  800b62:	e8 9a ff ff ff       	call   800b01 <strlen>
  800b67:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b6a:	ff 75 0c             	pushl  0xc(%ebp)
  800b6d:	01 d8                	add    %ebx,%eax
  800b6f:	50                   	push   %eax
  800b70:	e8 c5 ff ff ff       	call   800b3a <strcpy>
	return dst;
}
  800b75:	89 d8                	mov    %ebx,%eax
  800b77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 75 08             	mov    0x8(%ebp),%esi
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b8c:	89 f2                	mov    %esi,%edx
  800b8e:	eb 0f                	jmp    800b9f <strncpy+0x23>
		*dst++ = *src;
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	0f b6 01             	movzbl (%ecx),%eax
  800b96:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b99:	80 39 01             	cmpb   $0x1,(%ecx)
  800b9c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b9f:	39 da                	cmp    %ebx,%edx
  800ba1:	75 ed                	jne    800b90 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ba3:	89 f0                	mov    %esi,%eax
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 10             	mov    0x10(%ebp),%edx
  800bb7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bb9:	85 d2                	test   %edx,%edx
  800bbb:	74 21                	je     800bde <strlcpy+0x35>
  800bbd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc1:	89 f2                	mov    %esi,%edx
  800bc3:	eb 09                	jmp    800bce <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	83 c1 01             	add    $0x1,%ecx
  800bcb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bce:	39 c2                	cmp    %eax,%edx
  800bd0:	74 09                	je     800bdb <strlcpy+0x32>
  800bd2:	0f b6 19             	movzbl (%ecx),%ebx
  800bd5:	84 db                	test   %bl,%bl
  800bd7:	75 ec                	jne    800bc5 <strlcpy+0x1c>
  800bd9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bdb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bde:	29 f0                	sub    %esi,%eax
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bea:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bed:	eb 06                	jmp    800bf5 <strcmp+0x11>
		p++, q++;
  800bef:	83 c1 01             	add    $0x1,%ecx
  800bf2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bf5:	0f b6 01             	movzbl (%ecx),%eax
  800bf8:	84 c0                	test   %al,%al
  800bfa:	74 04                	je     800c00 <strcmp+0x1c>
  800bfc:	3a 02                	cmp    (%edx),%al
  800bfe:	74 ef                	je     800bef <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c00:	0f b6 c0             	movzbl %al,%eax
  800c03:	0f b6 12             	movzbl (%edx),%edx
  800c06:	29 d0                	sub    %edx,%eax
}
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c14:	89 c3                	mov    %eax,%ebx
  800c16:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c19:	eb 06                	jmp    800c21 <strncmp+0x17>
		n--, p++, q++;
  800c1b:	83 c0 01             	add    $0x1,%eax
  800c1e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c21:	39 d8                	cmp    %ebx,%eax
  800c23:	74 15                	je     800c3a <strncmp+0x30>
  800c25:	0f b6 08             	movzbl (%eax),%ecx
  800c28:	84 c9                	test   %cl,%cl
  800c2a:	74 04                	je     800c30 <strncmp+0x26>
  800c2c:	3a 0a                	cmp    (%edx),%cl
  800c2e:	74 eb                	je     800c1b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c30:	0f b6 00             	movzbl (%eax),%eax
  800c33:	0f b6 12             	movzbl (%edx),%edx
  800c36:	29 d0                	sub    %edx,%eax
  800c38:	eb 05                	jmp    800c3f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c4c:	eb 07                	jmp    800c55 <strchr+0x13>
		if (*s == c)
  800c4e:	38 ca                	cmp    %cl,%dl
  800c50:	74 0f                	je     800c61 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	0f b6 10             	movzbl (%eax),%edx
  800c58:	84 d2                	test   %dl,%dl
  800c5a:	75 f2                	jne    800c4e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c6d:	eb 03                	jmp    800c72 <strfind+0xf>
  800c6f:	83 c0 01             	add    $0x1,%eax
  800c72:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c75:	38 ca                	cmp    %cl,%dl
  800c77:	74 04                	je     800c7d <strfind+0x1a>
  800c79:	84 d2                	test   %dl,%dl
  800c7b:	75 f2                	jne    800c6f <strfind+0xc>
			break;
	return (char *) s;
}
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c8b:	85 c9                	test   %ecx,%ecx
  800c8d:	74 36                	je     800cc5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c95:	75 28                	jne    800cbf <memset+0x40>
  800c97:	f6 c1 03             	test   $0x3,%cl
  800c9a:	75 23                	jne    800cbf <memset+0x40>
		c &= 0xFF;
  800c9c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	c1 e3 08             	shl    $0x8,%ebx
  800ca5:	89 d6                	mov    %edx,%esi
  800ca7:	c1 e6 18             	shl    $0x18,%esi
  800caa:	89 d0                	mov    %edx,%eax
  800cac:	c1 e0 10             	shl    $0x10,%eax
  800caf:	09 f0                	or     %esi,%eax
  800cb1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cb3:	89 d8                	mov    %ebx,%eax
  800cb5:	09 d0                	or     %edx,%eax
  800cb7:	c1 e9 02             	shr    $0x2,%ecx
  800cba:	fc                   	cld    
  800cbb:	f3 ab                	rep stos %eax,%es:(%edi)
  800cbd:	eb 06                	jmp    800cc5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc2:	fc                   	cld    
  800cc3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cc5:	89 f8                	mov    %edi,%eax
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cda:	39 c6                	cmp    %eax,%esi
  800cdc:	73 35                	jae    800d13 <memmove+0x47>
  800cde:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce1:	39 d0                	cmp    %edx,%eax
  800ce3:	73 2e                	jae    800d13 <memmove+0x47>
		s += n;
		d += n;
  800ce5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce8:	89 d6                	mov    %edx,%esi
  800cea:	09 fe                	or     %edi,%esi
  800cec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cf2:	75 13                	jne    800d07 <memmove+0x3b>
  800cf4:	f6 c1 03             	test   $0x3,%cl
  800cf7:	75 0e                	jne    800d07 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800cf9:	83 ef 04             	sub    $0x4,%edi
  800cfc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cff:	c1 e9 02             	shr    $0x2,%ecx
  800d02:	fd                   	std    
  800d03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d05:	eb 09                	jmp    800d10 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d07:	83 ef 01             	sub    $0x1,%edi
  800d0a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d0d:	fd                   	std    
  800d0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d10:	fc                   	cld    
  800d11:	eb 1d                	jmp    800d30 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d13:	89 f2                	mov    %esi,%edx
  800d15:	09 c2                	or     %eax,%edx
  800d17:	f6 c2 03             	test   $0x3,%dl
  800d1a:	75 0f                	jne    800d2b <memmove+0x5f>
  800d1c:	f6 c1 03             	test   $0x3,%cl
  800d1f:	75 0a                	jne    800d2b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d21:	c1 e9 02             	shr    $0x2,%ecx
  800d24:	89 c7                	mov    %eax,%edi
  800d26:	fc                   	cld    
  800d27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d29:	eb 05                	jmp    800d30 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d2b:	89 c7                	mov    %eax,%edi
  800d2d:	fc                   	cld    
  800d2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d37:	ff 75 10             	pushl  0x10(%ebp)
  800d3a:	ff 75 0c             	pushl  0xc(%ebp)
  800d3d:	ff 75 08             	pushl  0x8(%ebp)
  800d40:	e8 87 ff ff ff       	call   800ccc <memmove>
}
  800d45:	c9                   	leave  
  800d46:	c3                   	ret    

00800d47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d52:	89 c6                	mov    %eax,%esi
  800d54:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d57:	eb 1a                	jmp    800d73 <memcmp+0x2c>
		if (*s1 != *s2)
  800d59:	0f b6 08             	movzbl (%eax),%ecx
  800d5c:	0f b6 1a             	movzbl (%edx),%ebx
  800d5f:	38 d9                	cmp    %bl,%cl
  800d61:	74 0a                	je     800d6d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d63:	0f b6 c1             	movzbl %cl,%eax
  800d66:	0f b6 db             	movzbl %bl,%ebx
  800d69:	29 d8                	sub    %ebx,%eax
  800d6b:	eb 0f                	jmp    800d7c <memcmp+0x35>
		s1++, s2++;
  800d6d:	83 c0 01             	add    $0x1,%eax
  800d70:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d73:	39 f0                	cmp    %esi,%eax
  800d75:	75 e2                	jne    800d59 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	53                   	push   %ebx
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d87:	89 c1                	mov    %eax,%ecx
  800d89:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d8c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d90:	eb 0a                	jmp    800d9c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d92:	0f b6 10             	movzbl (%eax),%edx
  800d95:	39 da                	cmp    %ebx,%edx
  800d97:	74 07                	je     800da0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d99:	83 c0 01             	add    $0x1,%eax
  800d9c:	39 c8                	cmp    %ecx,%eax
  800d9e:	72 f2                	jb     800d92 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da0:	5b                   	pop    %ebx
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800daf:	eb 03                	jmp    800db4 <strtol+0x11>
		s++;
  800db1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db4:	0f b6 01             	movzbl (%ecx),%eax
  800db7:	3c 20                	cmp    $0x20,%al
  800db9:	74 f6                	je     800db1 <strtol+0xe>
  800dbb:	3c 09                	cmp    $0x9,%al
  800dbd:	74 f2                	je     800db1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dbf:	3c 2b                	cmp    $0x2b,%al
  800dc1:	75 0a                	jne    800dcd <strtol+0x2a>
		s++;
  800dc3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800dcb:	eb 11                	jmp    800dde <strtol+0x3b>
  800dcd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dd2:	3c 2d                	cmp    $0x2d,%al
  800dd4:	75 08                	jne    800dde <strtol+0x3b>
		s++, neg = 1;
  800dd6:	83 c1 01             	add    $0x1,%ecx
  800dd9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dde:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800de4:	75 15                	jne    800dfb <strtol+0x58>
  800de6:	80 39 30             	cmpb   $0x30,(%ecx)
  800de9:	75 10                	jne    800dfb <strtol+0x58>
  800deb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800def:	75 7c                	jne    800e6d <strtol+0xca>
		s += 2, base = 16;
  800df1:	83 c1 02             	add    $0x2,%ecx
  800df4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800df9:	eb 16                	jmp    800e11 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800dfb:	85 db                	test   %ebx,%ebx
  800dfd:	75 12                	jne    800e11 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e04:	80 39 30             	cmpb   $0x30,(%ecx)
  800e07:	75 08                	jne    800e11 <strtol+0x6e>
		s++, base = 8;
  800e09:	83 c1 01             	add    $0x1,%ecx
  800e0c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax
  800e16:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e19:	0f b6 11             	movzbl (%ecx),%edx
  800e1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e1f:	89 f3                	mov    %esi,%ebx
  800e21:	80 fb 09             	cmp    $0x9,%bl
  800e24:	77 08                	ja     800e2e <strtol+0x8b>
			dig = *s - '0';
  800e26:	0f be d2             	movsbl %dl,%edx
  800e29:	83 ea 30             	sub    $0x30,%edx
  800e2c:	eb 22                	jmp    800e50 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e2e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e31:	89 f3                	mov    %esi,%ebx
  800e33:	80 fb 19             	cmp    $0x19,%bl
  800e36:	77 08                	ja     800e40 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e38:	0f be d2             	movsbl %dl,%edx
  800e3b:	83 ea 57             	sub    $0x57,%edx
  800e3e:	eb 10                	jmp    800e50 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e43:	89 f3                	mov    %esi,%ebx
  800e45:	80 fb 19             	cmp    $0x19,%bl
  800e48:	77 16                	ja     800e60 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e4a:	0f be d2             	movsbl %dl,%edx
  800e4d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e50:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e53:	7d 0b                	jge    800e60 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e55:	83 c1 01             	add    $0x1,%ecx
  800e58:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e5c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e5e:	eb b9                	jmp    800e19 <strtol+0x76>

	if (endptr)
  800e60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e64:	74 0d                	je     800e73 <strtol+0xd0>
		*endptr = (char *) s;
  800e66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e69:	89 0e                	mov    %ecx,(%esi)
  800e6b:	eb 06                	jmp    800e73 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e6d:	85 db                	test   %ebx,%ebx
  800e6f:	74 98                	je     800e09 <strtol+0x66>
  800e71:	eb 9e                	jmp    800e11 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	f7 da                	neg    %edx
  800e77:	85 ff                	test   %edi,%edi
  800e79:	0f 45 c2             	cmovne %edx,%eax
}
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	89 c7                	mov    %eax,%edi
  800e96:	89 c6                	mov    %eax,%esi
  800e98:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaa:	b8 01 00 00 00       	mov    $0x1,%eax
  800eaf:	89 d1                	mov    %edx,%ecx
  800eb1:	89 d3                	mov    %edx,%ebx
  800eb3:	89 d7                	mov    %edx,%edi
  800eb5:	89 d6                	mov    %edx,%esi
  800eb7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	89 cb                	mov    %ecx,%ebx
  800ed6:	89 cf                	mov    %ecx,%edi
  800ed8:	89 ce                	mov    %ecx,%esi
  800eda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800edc:	85 c0                	test   %eax,%eax
  800ede:	7e 17                	jle    800ef7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	50                   	push   %eax
  800ee4:	6a 03                	push   $0x3
  800ee6:	68 1f 2b 80 00       	push   $0x802b1f
  800eeb:	6a 23                	push   $0x23
  800eed:	68 3c 2b 80 00       	push   $0x802b3c
  800ef2:	e8 dc 13 00 00       	call   8022d3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	57                   	push   %edi
  800f03:	56                   	push   %esi
  800f04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f05:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f0f:	89 d1                	mov    %edx,%ecx
  800f11:	89 d3                	mov    %edx,%ebx
  800f13:	89 d7                	mov    %edx,%edi
  800f15:	89 d6                	mov    %edx,%esi
  800f17:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_yield>:

void
sys_yield(void)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f24:	ba 00 00 00 00       	mov    $0x0,%edx
  800f29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f2e:	89 d1                	mov    %edx,%ecx
  800f30:	89 d3                	mov    %edx,%ebx
  800f32:	89 d7                	mov    %edx,%edi
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	be 00 00 00 00       	mov    $0x0,%esi
  800f4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f59:	89 f7                	mov    %esi,%edi
  800f5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	7e 17                	jle    800f78 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	50                   	push   %eax
  800f65:	6a 04                	push   $0x4
  800f67:	68 1f 2b 80 00       	push   $0x802b1f
  800f6c:	6a 23                	push   $0x23
  800f6e:	68 3c 2b 80 00       	push   $0x802b3c
  800f73:	e8 5b 13 00 00       	call   8022d3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7b:	5b                   	pop    %ebx
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f89:	b8 05 00 00 00       	mov    $0x5,%eax
  800f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f91:	8b 55 08             	mov    0x8(%ebp),%edx
  800f94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9a:	8b 75 18             	mov    0x18(%ebp),%esi
  800f9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	7e 17                	jle    800fba <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	50                   	push   %eax
  800fa7:	6a 05                	push   $0x5
  800fa9:	68 1f 2b 80 00       	push   $0x802b1f
  800fae:	6a 23                	push   $0x23
  800fb0:	68 3c 2b 80 00       	push   $0x802b3c
  800fb5:	e8 19 13 00 00       	call   8022d3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd0:	b8 06 00 00 00       	mov    $0x6,%eax
  800fd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdb:	89 df                	mov    %ebx,%edi
  800fdd:	89 de                	mov    %ebx,%esi
  800fdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	7e 17                	jle    800ffc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	50                   	push   %eax
  800fe9:	6a 06                	push   $0x6
  800feb:	68 1f 2b 80 00       	push   $0x802b1f
  800ff0:	6a 23                	push   $0x23
  800ff2:	68 3c 2b 80 00       	push   $0x802b3c
  800ff7:	e8 d7 12 00 00       	call   8022d3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801012:	b8 08 00 00 00       	mov    $0x8,%eax
  801017:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101a:	8b 55 08             	mov    0x8(%ebp),%edx
  80101d:	89 df                	mov    %ebx,%edi
  80101f:	89 de                	mov    %ebx,%esi
  801021:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801023:	85 c0                	test   %eax,%eax
  801025:	7e 17                	jle    80103e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	50                   	push   %eax
  80102b:	6a 08                	push   $0x8
  80102d:	68 1f 2b 80 00       	push   $0x802b1f
  801032:	6a 23                	push   $0x23
  801034:	68 3c 2b 80 00       	push   $0x802b3c
  801039:	e8 95 12 00 00       	call   8022d3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80103e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	57                   	push   %edi
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
  80104c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801054:	b8 09 00 00 00       	mov    $0x9,%eax
  801059:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105c:	8b 55 08             	mov    0x8(%ebp),%edx
  80105f:	89 df                	mov    %ebx,%edi
  801061:	89 de                	mov    %ebx,%esi
  801063:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801065:	85 c0                	test   %eax,%eax
  801067:	7e 17                	jle    801080 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	50                   	push   %eax
  80106d:	6a 09                	push   $0x9
  80106f:	68 1f 2b 80 00       	push   $0x802b1f
  801074:	6a 23                	push   $0x23
  801076:	68 3c 2b 80 00       	push   $0x802b3c
  80107b:	e8 53 12 00 00       	call   8022d3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	57                   	push   %edi
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
  80108e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801091:	bb 00 00 00 00       	mov    $0x0,%ebx
  801096:	b8 0a 00 00 00       	mov    $0xa,%eax
  80109b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109e:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a1:	89 df                	mov    %ebx,%edi
  8010a3:	89 de                	mov    %ebx,%esi
  8010a5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	7e 17                	jle    8010c2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	50                   	push   %eax
  8010af:	6a 0a                	push   $0xa
  8010b1:	68 1f 2b 80 00       	push   $0x802b1f
  8010b6:	6a 23                	push   $0x23
  8010b8:	68 3c 2b 80 00       	push   $0x802b3c
  8010bd:	e8 11 12 00 00       	call   8022d3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	be 00 00 00 00       	mov    $0x0,%esi
  8010d5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010e6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fb:	b8 0d 00 00 00       	mov    $0xd,%eax
  801100:	8b 55 08             	mov    0x8(%ebp),%edx
  801103:	89 cb                	mov    %ecx,%ebx
  801105:	89 cf                	mov    %ecx,%edi
  801107:	89 ce                	mov    %ecx,%esi
  801109:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	7e 17                	jle    801126 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110f:	83 ec 0c             	sub    $0xc,%esp
  801112:	50                   	push   %eax
  801113:	6a 0d                	push   $0xd
  801115:	68 1f 2b 80 00       	push   $0x802b1f
  80111a:	6a 23                	push   $0x23
  80111c:	68 3c 2b 80 00       	push   $0x802b3c
  801121:	e8 ad 11 00 00       	call   8022d3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801134:	ba 00 00 00 00       	mov    $0x0,%edx
  801139:	b8 0e 00 00 00       	mov    $0xe,%eax
  80113e:	89 d1                	mov    %edx,%ecx
  801140:	89 d3                	mov    %edx,%ebx
  801142:	89 d7                	mov    %edx,%edi
  801144:	89 d6                	mov    %edx,%esi
  801146:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	57                   	push   %edi
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801156:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115b:	b8 0f 00 00 00       	mov    $0xf,%eax
  801160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801163:	8b 55 08             	mov    0x8(%ebp),%edx
  801166:	89 df                	mov    %ebx,%edi
  801168:	89 de                	mov    %ebx,%esi
  80116a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80116c:	85 c0                	test   %eax,%eax
  80116e:	7e 17                	jle    801187 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	50                   	push   %eax
  801174:	6a 0f                	push   $0xf
  801176:	68 1f 2b 80 00       	push   $0x802b1f
  80117b:	6a 23                	push   $0x23
  80117d:	68 3c 2b 80 00       	push   $0x802b3c
  801182:	e8 4c 11 00 00       	call   8022d3 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  801187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118a:	5b                   	pop    %ebx
  80118b:	5e                   	pop    %esi
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
  801195:	05 00 00 00 30       	add    $0x30000000,%eax
  80119a:	c1 e8 0c             	shr    $0xc,%eax
}
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8011aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011af:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 16             	shr    $0x16,%edx
  8011c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	74 11                	je     8011e3 <fd_alloc+0x2d>
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	c1 ea 0c             	shr    $0xc,%edx
  8011d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011de:	f6 c2 01             	test   $0x1,%dl
  8011e1:	75 09                	jne    8011ec <fd_alloc+0x36>
			*fd_store = fd;
  8011e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ea:	eb 17                	jmp    801203 <fd_alloc+0x4d>
  8011ec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f6:	75 c9                	jne    8011c1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120b:	83 f8 1f             	cmp    $0x1f,%eax
  80120e:	77 36                	ja     801246 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801210:	c1 e0 0c             	shl    $0xc,%eax
  801213:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801218:	89 c2                	mov    %eax,%edx
  80121a:	c1 ea 16             	shr    $0x16,%edx
  80121d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801224:	f6 c2 01             	test   $0x1,%dl
  801227:	74 24                	je     80124d <fd_lookup+0x48>
  801229:	89 c2                	mov    %eax,%edx
  80122b:	c1 ea 0c             	shr    $0xc,%edx
  80122e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801235:	f6 c2 01             	test   $0x1,%dl
  801238:	74 1a                	je     801254 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123d:	89 02                	mov    %eax,(%edx)
	return 0;
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
  801244:	eb 13                	jmp    801259 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801246:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124b:	eb 0c                	jmp    801259 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801252:	eb 05                	jmp    801259 <fd_lookup+0x54>
  801254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801264:	ba c8 2b 80 00       	mov    $0x802bc8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801269:	eb 13                	jmp    80127e <dev_lookup+0x23>
  80126b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80126e:	39 08                	cmp    %ecx,(%eax)
  801270:	75 0c                	jne    80127e <dev_lookup+0x23>
			*dev = devtab[i];
  801272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801275:	89 01                	mov    %eax,(%ecx)
			return 0;
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
  80127c:	eb 2e                	jmp    8012ac <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127e:	8b 02                	mov    (%edx),%eax
  801280:	85 c0                	test   %eax,%eax
  801282:	75 e7                	jne    80126b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801284:	a1 18 40 80 00       	mov    0x804018,%eax
  801289:	8b 40 48             	mov    0x48(%eax),%eax
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	51                   	push   %ecx
  801290:	50                   	push   %eax
  801291:	68 4c 2b 80 00       	push   $0x802b4c
  801296:	e8 1a f3 ff ff       	call   8005b5 <cprintf>
	*dev = 0;
  80129b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ac:	c9                   	leave  
  8012ad:	c3                   	ret    

008012ae <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	56                   	push   %esi
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 10             	sub    $0x10,%esp
  8012b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c6:	c1 e8 0c             	shr    $0xc,%eax
  8012c9:	50                   	push   %eax
  8012ca:	e8 36 ff ff ff       	call   801205 <fd_lookup>
  8012cf:	83 c4 08             	add    $0x8,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 05                	js     8012db <fd_close+0x2d>
	    || fd != fd2)
  8012d6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d9:	74 0c                	je     8012e7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012db:	84 db                	test   %bl,%bl
  8012dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e2:	0f 44 c2             	cmove  %edx,%eax
  8012e5:	eb 41                	jmp    801328 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	ff 36                	pushl  (%esi)
  8012f0:	e8 66 ff ff ff       	call   80125b <dev_lookup>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 1a                	js     801318 <fd_close+0x6a>
		if (dev->dev_close)
  8012fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801301:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801309:	85 c0                	test   %eax,%eax
  80130b:	74 0b                	je     801318 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	56                   	push   %esi
  801311:	ff d0                	call   *%eax
  801313:	89 c3                	mov    %eax,%ebx
  801315:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	56                   	push   %esi
  80131c:	6a 00                	push   $0x0
  80131e:	e8 9f fc ff ff       	call   800fc2 <sys_page_unmap>
	return r;
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	89 d8                	mov    %ebx,%eax
}
  801328:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 75 08             	pushl  0x8(%ebp)
  80133c:	e8 c4 fe ff ff       	call   801205 <fd_lookup>
  801341:	83 c4 08             	add    $0x8,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 10                	js     801358 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	6a 01                	push   $0x1
  80134d:	ff 75 f4             	pushl  -0xc(%ebp)
  801350:	e8 59 ff ff ff       	call   8012ae <fd_close>
  801355:	83 c4 10             	add    $0x10,%esp
}
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <close_all>:

void
close_all(void)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801361:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	53                   	push   %ebx
  80136a:	e8 c0 ff ff ff       	call   80132f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136f:	83 c3 01             	add    $0x1,%ebx
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	83 fb 20             	cmp    $0x20,%ebx
  801378:	75 ec                	jne    801366 <close_all+0xc>
		close(i);
}
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	57                   	push   %edi
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 2c             	sub    $0x2c,%esp
  801388:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 6e fe ff ff       	call   801205 <fd_lookup>
  801397:	83 c4 08             	add    $0x8,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	0f 88 c1 00 00 00    	js     801463 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	56                   	push   %esi
  8013a6:	e8 84 ff ff ff       	call   80132f <close>

	newfd = INDEX2FD(newfdnum);
  8013ab:	89 f3                	mov    %esi,%ebx
  8013ad:	c1 e3 0c             	shl    $0xc,%ebx
  8013b0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b6:	83 c4 04             	add    $0x4,%esp
  8013b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013bc:	e8 de fd ff ff       	call   80119f <fd2data>
  8013c1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c3:	89 1c 24             	mov    %ebx,(%esp)
  8013c6:	e8 d4 fd ff ff       	call   80119f <fd2data>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d1:	89 f8                	mov    %edi,%eax
  8013d3:	c1 e8 16             	shr    $0x16,%eax
  8013d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013dd:	a8 01                	test   $0x1,%al
  8013df:	74 37                	je     801418 <dup+0x99>
  8013e1:	89 f8                	mov    %edi,%eax
  8013e3:	c1 e8 0c             	shr    $0xc,%eax
  8013e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ed:	f6 c2 01             	test   $0x1,%dl
  8013f0:	74 26                	je     801418 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801401:	50                   	push   %eax
  801402:	ff 75 d4             	pushl  -0x2c(%ebp)
  801405:	6a 00                	push   $0x0
  801407:	57                   	push   %edi
  801408:	6a 00                	push   $0x0
  80140a:	e8 71 fb ff ff       	call   800f80 <sys_page_map>
  80140f:	89 c7                	mov    %eax,%edi
  801411:	83 c4 20             	add    $0x20,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 2e                	js     801446 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801418:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141b:	89 d0                	mov    %edx,%eax
  80141d:	c1 e8 0c             	shr    $0xc,%eax
  801420:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	25 07 0e 00 00       	and    $0xe07,%eax
  80142f:	50                   	push   %eax
  801430:	53                   	push   %ebx
  801431:	6a 00                	push   $0x0
  801433:	52                   	push   %edx
  801434:	6a 00                	push   $0x0
  801436:	e8 45 fb ff ff       	call   800f80 <sys_page_map>
  80143b:	89 c7                	mov    %eax,%edi
  80143d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801440:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801442:	85 ff                	test   %edi,%edi
  801444:	79 1d                	jns    801463 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	53                   	push   %ebx
  80144a:	6a 00                	push   $0x0
  80144c:	e8 71 fb ff ff       	call   800fc2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801451:	83 c4 08             	add    $0x8,%esp
  801454:	ff 75 d4             	pushl  -0x2c(%ebp)
  801457:	6a 00                	push   $0x0
  801459:	e8 64 fb ff ff       	call   800fc2 <sys_page_unmap>
	return r;
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	89 f8                	mov    %edi,%eax
}
  801463:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801466:	5b                   	pop    %ebx
  801467:	5e                   	pop    %esi
  801468:	5f                   	pop    %edi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    

0080146b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	53                   	push   %ebx
  80146f:	83 ec 14             	sub    $0x14,%esp
  801472:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801475:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801478:	50                   	push   %eax
  801479:	53                   	push   %ebx
  80147a:	e8 86 fd ff ff       	call   801205 <fd_lookup>
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	89 c2                	mov    %eax,%edx
  801484:	85 c0                	test   %eax,%eax
  801486:	78 6d                	js     8014f5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	ff 30                	pushl  (%eax)
  801494:	e8 c2 fd ff ff       	call   80125b <dev_lookup>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 4c                	js     8014ec <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a3:	8b 42 08             	mov    0x8(%edx),%eax
  8014a6:	83 e0 03             	and    $0x3,%eax
  8014a9:	83 f8 01             	cmp    $0x1,%eax
  8014ac:	75 21                	jne    8014cf <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ae:	a1 18 40 80 00       	mov    0x804018,%eax
  8014b3:	8b 40 48             	mov    0x48(%eax),%eax
  8014b6:	83 ec 04             	sub    $0x4,%esp
  8014b9:	53                   	push   %ebx
  8014ba:	50                   	push   %eax
  8014bb:	68 8d 2b 80 00       	push   $0x802b8d
  8014c0:	e8 f0 f0 ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cd:	eb 26                	jmp    8014f5 <read+0x8a>
	}
	if (!dev->dev_read)
  8014cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d2:	8b 40 08             	mov    0x8(%eax),%eax
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	74 17                	je     8014f0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	ff 75 10             	pushl  0x10(%ebp)
  8014df:	ff 75 0c             	pushl  0xc(%ebp)
  8014e2:	52                   	push   %edx
  8014e3:	ff d0                	call   *%eax
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	eb 09                	jmp    8014f5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ec:	89 c2                	mov    %eax,%edx
  8014ee:	eb 05                	jmp    8014f5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014f5:	89 d0                	mov    %edx,%eax
  8014f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	57                   	push   %edi
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	8b 7d 08             	mov    0x8(%ebp),%edi
  801508:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801510:	eb 21                	jmp    801533 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801512:	83 ec 04             	sub    $0x4,%esp
  801515:	89 f0                	mov    %esi,%eax
  801517:	29 d8                	sub    %ebx,%eax
  801519:	50                   	push   %eax
  80151a:	89 d8                	mov    %ebx,%eax
  80151c:	03 45 0c             	add    0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	57                   	push   %edi
  801521:	e8 45 ff ff ff       	call   80146b <read>
		if (m < 0)
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 10                	js     80153d <readn+0x41>
			return m;
		if (m == 0)
  80152d:	85 c0                	test   %eax,%eax
  80152f:	74 0a                	je     80153b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801531:	01 c3                	add    %eax,%ebx
  801533:	39 f3                	cmp    %esi,%ebx
  801535:	72 db                	jb     801512 <readn+0x16>
  801537:	89 d8                	mov    %ebx,%eax
  801539:	eb 02                	jmp    80153d <readn+0x41>
  80153b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5f                   	pop    %edi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 14             	sub    $0x14,%esp
  80154c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	53                   	push   %ebx
  801554:	e8 ac fc ff ff       	call   801205 <fd_lookup>
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 68                	js     8015ca <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156c:	ff 30                	pushl  (%eax)
  80156e:	e8 e8 fc ff ff       	call   80125b <dev_lookup>
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 47                	js     8015c1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801581:	75 21                	jne    8015a4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801583:	a1 18 40 80 00       	mov    0x804018,%eax
  801588:	8b 40 48             	mov    0x48(%eax),%eax
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	53                   	push   %ebx
  80158f:	50                   	push   %eax
  801590:	68 a9 2b 80 00       	push   $0x802ba9
  801595:	e8 1b f0 ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a2:	eb 26                	jmp    8015ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8015aa:	85 d2                	test   %edx,%edx
  8015ac:	74 17                	je     8015c5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	ff 75 10             	pushl  0x10(%ebp)
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	50                   	push   %eax
  8015b8:	ff d2                	call   *%edx
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 09                	jmp    8015ca <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	eb 05                	jmp    8015ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015ca:	89 d0                	mov    %edx,%eax
  8015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	ff 75 08             	pushl  0x8(%ebp)
  8015de:	e8 22 fc ff ff       	call   801205 <fd_lookup>
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 0e                	js     8015f8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 14             	sub    $0x14,%esp
  801601:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801604:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	53                   	push   %ebx
  801609:	e8 f7 fb ff ff       	call   801205 <fd_lookup>
  80160e:	83 c4 08             	add    $0x8,%esp
  801611:	89 c2                	mov    %eax,%edx
  801613:	85 c0                	test   %eax,%eax
  801615:	78 65                	js     80167c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	ff 30                	pushl  (%eax)
  801623:	e8 33 fc ff ff       	call   80125b <dev_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 44                	js     801673 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801632:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801636:	75 21                	jne    801659 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801638:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163d:	8b 40 48             	mov    0x48(%eax),%eax
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	53                   	push   %ebx
  801644:	50                   	push   %eax
  801645:	68 6c 2b 80 00       	push   $0x802b6c
  80164a:	e8 66 ef ff ff       	call   8005b5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801657:	eb 23                	jmp    80167c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801659:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165c:	8b 52 18             	mov    0x18(%edx),%edx
  80165f:	85 d2                	test   %edx,%edx
  801661:	74 14                	je     801677 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	50                   	push   %eax
  80166a:	ff d2                	call   *%edx
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb 09                	jmp    80167c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	89 c2                	mov    %eax,%edx
  801675:	eb 05                	jmp    80167c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801677:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80167c:	89 d0                	mov    %edx,%eax
  80167e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 14             	sub    $0x14,%esp
  80168a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	ff 75 08             	pushl  0x8(%ebp)
  801694:	e8 6c fb ff ff       	call   801205 <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 58                	js     8016fa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	ff 30                	pushl  (%eax)
  8016ae:	e8 a8 fb ff ff       	call   80125b <dev_lookup>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 37                	js     8016f1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c1:	74 32                	je     8016f5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cd:	00 00 00 
	stat->st_isdir = 0;
  8016d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d7:	00 00 00 
	stat->st_dev = dev;
  8016da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	53                   	push   %ebx
  8016e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e7:	ff 50 14             	call   *0x14(%eax)
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	eb 09                	jmp    8016fa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	eb 05                	jmp    8016fa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016fa:	89 d0                	mov    %edx,%eax
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	6a 00                	push   $0x0
  80170b:	ff 75 08             	pushl  0x8(%ebp)
  80170e:	e8 d6 01 00 00       	call   8018e9 <open>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 1b                	js     801737 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80171c:	83 ec 08             	sub    $0x8,%esp
  80171f:	ff 75 0c             	pushl  0xc(%ebp)
  801722:	50                   	push   %eax
  801723:	e8 5b ff ff ff       	call   801683 <fstat>
  801728:	89 c6                	mov    %eax,%esi
	close(fd);
  80172a:	89 1c 24             	mov    %ebx,(%esp)
  80172d:	e8 fd fb ff ff       	call   80132f <close>
	return r;
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	89 f0                	mov    %esi,%eax
}
  801737:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173a:	5b                   	pop    %ebx
  80173b:	5e                   	pop    %esi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	89 c6                	mov    %eax,%esi
  801745:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801747:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  80174e:	75 12                	jne    801762 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801750:	83 ec 0c             	sub    $0xc,%esp
  801753:	6a 01                	push   $0x1
  801755:	e8 7a 0c 00 00       	call   8023d4 <ipc_find_env>
  80175a:	a3 10 40 80 00       	mov    %eax,0x804010
  80175f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801762:	6a 07                	push   $0x7
  801764:	68 00 50 80 00       	push   $0x805000
  801769:	56                   	push   %esi
  80176a:	ff 35 10 40 80 00    	pushl  0x804010
  801770:	e8 0b 0c 00 00       	call   802380 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801775:	83 c4 0c             	add    $0xc,%esp
  801778:	6a 00                	push   $0x0
  80177a:	53                   	push   %ebx
  80177b:	6a 00                	push   $0x0
  80177d:	e8 97 0b 00 00       	call   802319 <ipc_recv>
}
  801782:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178f:	8b 45 08             	mov    0x8(%ebp),%eax
  801792:	8b 40 0c             	mov    0xc(%eax),%eax
  801795:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ac:	e8 8d ff ff ff       	call   80173e <fsipc>
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ce:	e8 6b ff ff ff       	call   80173e <fsipc>
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f4:	e8 45 ff ff ff       	call   80173e <fsipc>
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 2c                	js     801829 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	68 00 50 80 00       	push   $0x805000
  801805:	53                   	push   %ebx
  801806:	e8 2f f3 ff ff       	call   800b3a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180b:	a1 80 50 80 00       	mov    0x805080,%eax
  801810:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801816:	a1 84 50 80 00       	mov    0x805084,%eax
  80181b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 0c             	sub    $0xc,%esp
  801834:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801837:	8b 55 08             	mov    0x8(%ebp),%edx
  80183a:	8b 52 0c             	mov    0xc(%edx),%edx
  80183d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801843:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801848:	50                   	push   %eax
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	68 08 50 80 00       	push   $0x805008
  801851:	e8 76 f4 ff ff       	call   800ccc <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 04 00 00 00       	mov    $0x4,%eax
  801860:	e8 d9 fe ff ff       	call   80173e <fsipc>

}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	8b 40 0c             	mov    0xc(%eax),%eax
  801875:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80187a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801880:	ba 00 00 00 00       	mov    $0x0,%edx
  801885:	b8 03 00 00 00       	mov    $0x3,%eax
  80188a:	e8 af fe ff ff       	call   80173e <fsipc>
  80188f:	89 c3                	mov    %eax,%ebx
  801891:	85 c0                	test   %eax,%eax
  801893:	78 4b                	js     8018e0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801895:	39 c6                	cmp    %eax,%esi
  801897:	73 16                	jae    8018af <devfile_read+0x48>
  801899:	68 dc 2b 80 00       	push   $0x802bdc
  80189e:	68 e3 2b 80 00       	push   $0x802be3
  8018a3:	6a 7c                	push   $0x7c
  8018a5:	68 f8 2b 80 00       	push   $0x802bf8
  8018aa:	e8 24 0a 00 00       	call   8022d3 <_panic>
	assert(r <= PGSIZE);
  8018af:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b4:	7e 16                	jle    8018cc <devfile_read+0x65>
  8018b6:	68 03 2c 80 00       	push   $0x802c03
  8018bb:	68 e3 2b 80 00       	push   $0x802be3
  8018c0:	6a 7d                	push   $0x7d
  8018c2:	68 f8 2b 80 00       	push   $0x802bf8
  8018c7:	e8 07 0a 00 00       	call   8022d3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018cc:	83 ec 04             	sub    $0x4,%esp
  8018cf:	50                   	push   %eax
  8018d0:	68 00 50 80 00       	push   $0x805000
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	e8 ef f3 ff ff       	call   800ccc <memmove>
	return r;
  8018dd:	83 c4 10             	add    $0x10,%esp
}
  8018e0:	89 d8                	mov    %ebx,%eax
  8018e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	5d                   	pop    %ebp
  8018e8:	c3                   	ret    

008018e9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	53                   	push   %ebx
  8018ed:	83 ec 20             	sub    $0x20,%esp
  8018f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f3:	53                   	push   %ebx
  8018f4:	e8 08 f2 ff ff       	call   800b01 <strlen>
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801901:	7f 67                	jg     80196a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801909:	50                   	push   %eax
  80190a:	e8 a7 f8 ff ff       	call   8011b6 <fd_alloc>
  80190f:	83 c4 10             	add    $0x10,%esp
		return r;
  801912:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801914:	85 c0                	test   %eax,%eax
  801916:	78 57                	js     80196f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	53                   	push   %ebx
  80191c:	68 00 50 80 00       	push   $0x805000
  801921:	e8 14 f2 ff ff       	call   800b3a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801926:	8b 45 0c             	mov    0xc(%ebp),%eax
  801929:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801931:	b8 01 00 00 00       	mov    $0x1,%eax
  801936:	e8 03 fe ff ff       	call   80173e <fsipc>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	79 14                	jns    801958 <open+0x6f>
		fd_close(fd, 0);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	6a 00                	push   $0x0
  801949:	ff 75 f4             	pushl  -0xc(%ebp)
  80194c:	e8 5d f9 ff ff       	call   8012ae <fd_close>
		return r;
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	89 da                	mov    %ebx,%edx
  801956:	eb 17                	jmp    80196f <open+0x86>
	}

	return fd2num(fd);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	ff 75 f4             	pushl  -0xc(%ebp)
  80195e:	e8 2c f8 ff ff       	call   80118f <fd2num>
  801963:	89 c2                	mov    %eax,%edx
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	eb 05                	jmp    80196f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80196a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196f:	89 d0                	mov    %edx,%eax
  801971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197c:	ba 00 00 00 00       	mov    $0x0,%edx
  801981:	b8 08 00 00 00       	mov    $0x8,%eax
  801986:	e8 b3 fd ff ff       	call   80173e <fsipc>
}
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801993:	68 0f 2c 80 00       	push   $0x802c0f
  801998:	ff 75 0c             	pushl  0xc(%ebp)
  80199b:	e8 9a f1 ff ff       	call   800b3a <strcpy>
	return 0;
}
  8019a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 10             	sub    $0x10,%esp
  8019ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019b1:	53                   	push   %ebx
  8019b2:	e8 56 0a 00 00       	call   80240d <pageref>
  8019b7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019ba:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019bf:	83 f8 01             	cmp    $0x1,%eax
  8019c2:	75 10                	jne    8019d4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019c4:	83 ec 0c             	sub    $0xc,%esp
  8019c7:	ff 73 0c             	pushl  0xc(%ebx)
  8019ca:	e8 c0 02 00 00       	call   801c8f <nsipc_close>
  8019cf:	89 c2                	mov    %eax,%edx
  8019d1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019d4:	89 d0                	mov    %edx,%eax
  8019d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019e1:	6a 00                	push   $0x0
  8019e3:	ff 75 10             	pushl  0x10(%ebp)
  8019e6:	ff 75 0c             	pushl  0xc(%ebp)
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	ff 70 0c             	pushl  0xc(%eax)
  8019ef:	e8 78 03 00 00       	call   801d6c <nsipc_send>
}
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019fc:	6a 00                	push   $0x0
  8019fe:	ff 75 10             	pushl  0x10(%ebp)
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	ff 70 0c             	pushl  0xc(%eax)
  801a0a:	e8 f1 02 00 00       	call   801d00 <nsipc_recv>
}
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a17:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a1a:	52                   	push   %edx
  801a1b:	50                   	push   %eax
  801a1c:	e8 e4 f7 ff ff       	call   801205 <fd_lookup>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 17                	js     801a3f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a31:	39 08                	cmp    %ecx,(%eax)
  801a33:	75 05                	jne    801a3a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a35:	8b 40 0c             	mov    0xc(%eax),%eax
  801a38:	eb 05                	jmp    801a3f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a3a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	83 ec 1c             	sub    $0x1c,%esp
  801a49:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	50                   	push   %eax
  801a4f:	e8 62 f7 ff ff       	call   8011b6 <fd_alloc>
  801a54:	89 c3                	mov    %eax,%ebx
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	78 1b                	js     801a78 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a5d:	83 ec 04             	sub    $0x4,%esp
  801a60:	68 07 04 00 00       	push   $0x407
  801a65:	ff 75 f4             	pushl  -0xc(%ebp)
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 ce f4 ff ff       	call   800f3d <sys_page_alloc>
  801a6f:	89 c3                	mov    %eax,%ebx
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	85 c0                	test   %eax,%eax
  801a76:	79 10                	jns    801a88 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	56                   	push   %esi
  801a7c:	e8 0e 02 00 00       	call   801c8f <nsipc_close>
		return r;
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	89 d8                	mov    %ebx,%eax
  801a86:	eb 24                	jmp    801aac <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a91:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a96:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a9d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	50                   	push   %eax
  801aa4:	e8 e6 f6 ff ff       	call   80118f <fd2num>
  801aa9:	83 c4 10             	add    $0x10,%esp
}
  801aac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	e8 50 ff ff ff       	call   801a11 <fd2sockid>
		return r;
  801ac1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 1f                	js     801ae6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	ff 75 10             	pushl  0x10(%ebp)
  801acd:	ff 75 0c             	pushl  0xc(%ebp)
  801ad0:	50                   	push   %eax
  801ad1:	e8 12 01 00 00       	call   801be8 <nsipc_accept>
  801ad6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 07                	js     801ae6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801adf:	e8 5d ff ff ff       	call   801a41 <alloc_sockfd>
  801ae4:	89 c1                	mov    %eax,%ecx
}
  801ae6:	89 c8                	mov    %ecx,%eax
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	e8 19 ff ff ff       	call   801a11 <fd2sockid>
  801af8:	85 c0                	test   %eax,%eax
  801afa:	78 12                	js     801b0e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801afc:	83 ec 04             	sub    $0x4,%esp
  801aff:	ff 75 10             	pushl  0x10(%ebp)
  801b02:	ff 75 0c             	pushl  0xc(%ebp)
  801b05:	50                   	push   %eax
  801b06:	e8 2d 01 00 00       	call   801c38 <nsipc_bind>
  801b0b:	83 c4 10             	add    $0x10,%esp
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <shutdown>:

int
shutdown(int s, int how)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	e8 f3 fe ff ff       	call   801a11 <fd2sockid>
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 0f                	js     801b31 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b22:	83 ec 08             	sub    $0x8,%esp
  801b25:	ff 75 0c             	pushl  0xc(%ebp)
  801b28:	50                   	push   %eax
  801b29:	e8 3f 01 00 00       	call   801c6d <nsipc_shutdown>
  801b2e:	83 c4 10             	add    $0x10,%esp
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	e8 d0 fe ff ff       	call   801a11 <fd2sockid>
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 12                	js     801b57 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b45:	83 ec 04             	sub    $0x4,%esp
  801b48:	ff 75 10             	pushl  0x10(%ebp)
  801b4b:	ff 75 0c             	pushl  0xc(%ebp)
  801b4e:	50                   	push   %eax
  801b4f:	e8 55 01 00 00       	call   801ca9 <nsipc_connect>
  801b54:	83 c4 10             	add    $0x10,%esp
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <listen>:

int
listen(int s, int backlog)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	e8 aa fe ff ff       	call   801a11 <fd2sockid>
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 0f                	js     801b7a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b6b:	83 ec 08             	sub    $0x8,%esp
  801b6e:	ff 75 0c             	pushl  0xc(%ebp)
  801b71:	50                   	push   %eax
  801b72:	e8 67 01 00 00       	call   801cde <nsipc_listen>
  801b77:	83 c4 10             	add    $0x10,%esp
}
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b82:	ff 75 10             	pushl  0x10(%ebp)
  801b85:	ff 75 0c             	pushl  0xc(%ebp)
  801b88:	ff 75 08             	pushl  0x8(%ebp)
  801b8b:	e8 3a 02 00 00       	call   801dca <nsipc_socket>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 05                	js     801b9c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b97:	e8 a5 fe ff ff       	call   801a41 <alloc_sockfd>
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 04             	sub    $0x4,%esp
  801ba5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba7:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801bae:	75 12                	jne    801bc2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bb0:	83 ec 0c             	sub    $0xc,%esp
  801bb3:	6a 02                	push   $0x2
  801bb5:	e8 1a 08 00 00       	call   8023d4 <ipc_find_env>
  801bba:	a3 14 40 80 00       	mov    %eax,0x804014
  801bbf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bc2:	6a 07                	push   $0x7
  801bc4:	68 00 60 80 00       	push   $0x806000
  801bc9:	53                   	push   %ebx
  801bca:	ff 35 14 40 80 00    	pushl  0x804014
  801bd0:	e8 ab 07 00 00       	call   802380 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd5:	83 c4 0c             	add    $0xc,%esp
  801bd8:	6a 00                	push   $0x0
  801bda:	6a 00                	push   $0x0
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 36 07 00 00       	call   802319 <ipc_recv>
}
  801be3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bf8:	8b 06                	mov    (%esi),%eax
  801bfa:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bff:	b8 01 00 00 00       	mov    $0x1,%eax
  801c04:	e8 95 ff ff ff       	call   801b9e <nsipc>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 20                	js     801c2f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c0f:	83 ec 04             	sub    $0x4,%esp
  801c12:	ff 35 10 60 80 00    	pushl  0x806010
  801c18:	68 00 60 80 00       	push   $0x806000
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	e8 a7 f0 ff ff       	call   800ccc <memmove>
		*addrlen = ret->ret_addrlen;
  801c25:	a1 10 60 80 00       	mov    0x806010,%eax
  801c2a:	89 06                	mov    %eax,(%esi)
  801c2c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c2f:	89 d8                	mov    %ebx,%eax
  801c31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c4a:	53                   	push   %ebx
  801c4b:	ff 75 0c             	pushl  0xc(%ebp)
  801c4e:	68 04 60 80 00       	push   $0x806004
  801c53:	e8 74 f0 ff ff       	call   800ccc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c58:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c5e:	b8 02 00 00 00       	mov    $0x2,%eax
  801c63:	e8 36 ff ff ff       	call   801b9e <nsipc>
}
  801c68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c83:	b8 03 00 00 00       	mov    $0x3,%eax
  801c88:	e8 11 ff ff ff       	call   801b9e <nsipc>
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <nsipc_close>:

int
nsipc_close(int s)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c9d:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca2:	e8 f7 fe ff ff       	call   801b9e <nsipc>
}
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	53                   	push   %ebx
  801cad:	83 ec 08             	sub    $0x8,%esp
  801cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cbb:	53                   	push   %ebx
  801cbc:	ff 75 0c             	pushl  0xc(%ebp)
  801cbf:	68 04 60 80 00       	push   $0x806004
  801cc4:	e8 03 f0 ff ff       	call   800ccc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cc9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ccf:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd4:	e8 c5 fe ff ff       	call   801b9e <nsipc>
}
  801cd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cef:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cf4:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf9:	e8 a0 fe ff ff       	call   801b9e <nsipc>
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d08:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d10:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d16:	8b 45 14             	mov    0x14(%ebp),%eax
  801d19:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d1e:	b8 07 00 00 00       	mov    $0x7,%eax
  801d23:	e8 76 fe ff ff       	call   801b9e <nsipc>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 35                	js     801d63 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d2e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d33:	7f 04                	jg     801d39 <nsipc_recv+0x39>
  801d35:	39 c6                	cmp    %eax,%esi
  801d37:	7d 16                	jge    801d4f <nsipc_recv+0x4f>
  801d39:	68 1b 2c 80 00       	push   $0x802c1b
  801d3e:	68 e3 2b 80 00       	push   $0x802be3
  801d43:	6a 62                	push   $0x62
  801d45:	68 30 2c 80 00       	push   $0x802c30
  801d4a:	e8 84 05 00 00       	call   8022d3 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	50                   	push   %eax
  801d53:	68 00 60 80 00       	push   $0x806000
  801d58:	ff 75 0c             	pushl  0xc(%ebp)
  801d5b:	e8 6c ef ff ff       	call   800ccc <memmove>
  801d60:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d63:	89 d8                	mov    %ebx,%eax
  801d65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    

00801d6c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	53                   	push   %ebx
  801d70:	83 ec 04             	sub    $0x4,%esp
  801d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d7e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d84:	7e 16                	jle    801d9c <nsipc_send+0x30>
  801d86:	68 3c 2c 80 00       	push   $0x802c3c
  801d8b:	68 e3 2b 80 00       	push   $0x802be3
  801d90:	6a 6d                	push   $0x6d
  801d92:	68 30 2c 80 00       	push   $0x802c30
  801d97:	e8 37 05 00 00       	call   8022d3 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	53                   	push   %ebx
  801da0:	ff 75 0c             	pushl  0xc(%ebp)
  801da3:	68 0c 60 80 00       	push   $0x80600c
  801da8:	e8 1f ef ff ff       	call   800ccc <memmove>
	nsipcbuf.send.req_size = size;
  801dad:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801db3:	8b 45 14             	mov    0x14(%ebp),%eax
  801db6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc0:	e8 d9 fd ff ff       	call   801b9e <nsipc>
}
  801dc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddb:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801de0:	8b 45 10             	mov    0x10(%ebp),%eax
  801de3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801de8:	b8 09 00 00 00       	mov    $0x9,%eax
  801ded:	e8 ac fd ff ff       	call   801b9e <nsipc>
}
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	56                   	push   %esi
  801df8:	53                   	push   %ebx
  801df9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	ff 75 08             	pushl  0x8(%ebp)
  801e02:	e8 98 f3 ff ff       	call   80119f <fd2data>
  801e07:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e09:	83 c4 08             	add    $0x8,%esp
  801e0c:	68 48 2c 80 00       	push   $0x802c48
  801e11:	53                   	push   %ebx
  801e12:	e8 23 ed ff ff       	call   800b3a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e17:	8b 46 04             	mov    0x4(%esi),%eax
  801e1a:	2b 06                	sub    (%esi),%eax
  801e1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e29:	00 00 00 
	stat->st_dev = &devpipe;
  801e2c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e33:	30 80 00 
	return 0;
}
  801e36:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3e:	5b                   	pop    %ebx
  801e3f:	5e                   	pop    %esi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    

00801e42 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	53                   	push   %ebx
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e4c:	53                   	push   %ebx
  801e4d:	6a 00                	push   $0x0
  801e4f:	e8 6e f1 ff ff       	call   800fc2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e54:	89 1c 24             	mov    %ebx,(%esp)
  801e57:	e8 43 f3 ff ff       	call   80119f <fd2data>
  801e5c:	83 c4 08             	add    $0x8,%esp
  801e5f:	50                   	push   %eax
  801e60:	6a 00                	push   $0x0
  801e62:	e8 5b f1 ff ff       	call   800fc2 <sys_page_unmap>
}
  801e67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	57                   	push   %edi
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	83 ec 1c             	sub    $0x1c,%esp
  801e75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e78:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e7a:	a1 18 40 80 00       	mov    0x804018,%eax
  801e7f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	ff 75 e0             	pushl  -0x20(%ebp)
  801e88:	e8 80 05 00 00       	call   80240d <pageref>
  801e8d:	89 c3                	mov    %eax,%ebx
  801e8f:	89 3c 24             	mov    %edi,(%esp)
  801e92:	e8 76 05 00 00       	call   80240d <pageref>
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	39 c3                	cmp    %eax,%ebx
  801e9c:	0f 94 c1             	sete   %cl
  801e9f:	0f b6 c9             	movzbl %cl,%ecx
  801ea2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ea5:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801eab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801eae:	39 ce                	cmp    %ecx,%esi
  801eb0:	74 1b                	je     801ecd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801eb2:	39 c3                	cmp    %eax,%ebx
  801eb4:	75 c4                	jne    801e7a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb6:	8b 42 58             	mov    0x58(%edx),%eax
  801eb9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ebc:	50                   	push   %eax
  801ebd:	56                   	push   %esi
  801ebe:	68 4f 2c 80 00       	push   $0x802c4f
  801ec3:	e8 ed e6 ff ff       	call   8005b5 <cprintf>
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	eb ad                	jmp    801e7a <_pipeisclosed+0xe>
	}
}
  801ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	57                   	push   %edi
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	83 ec 28             	sub    $0x28,%esp
  801ee1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ee4:	56                   	push   %esi
  801ee5:	e8 b5 f2 ff ff       	call   80119f <fd2data>
  801eea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef4:	eb 4b                	jmp    801f41 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ef6:	89 da                	mov    %ebx,%edx
  801ef8:	89 f0                	mov    %esi,%eax
  801efa:	e8 6d ff ff ff       	call   801e6c <_pipeisclosed>
  801eff:	85 c0                	test   %eax,%eax
  801f01:	75 48                	jne    801f4b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f03:	e8 16 f0 ff ff       	call   800f1e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f08:	8b 43 04             	mov    0x4(%ebx),%eax
  801f0b:	8b 0b                	mov    (%ebx),%ecx
  801f0d:	8d 51 20             	lea    0x20(%ecx),%edx
  801f10:	39 d0                	cmp    %edx,%eax
  801f12:	73 e2                	jae    801ef6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f17:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f1b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f1e:	89 c2                	mov    %eax,%edx
  801f20:	c1 fa 1f             	sar    $0x1f,%edx
  801f23:	89 d1                	mov    %edx,%ecx
  801f25:	c1 e9 1b             	shr    $0x1b,%ecx
  801f28:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f2b:	83 e2 1f             	and    $0x1f,%edx
  801f2e:	29 ca                	sub    %ecx,%edx
  801f30:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f34:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f38:	83 c0 01             	add    $0x1,%eax
  801f3b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3e:	83 c7 01             	add    $0x1,%edi
  801f41:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f44:	75 c2                	jne    801f08 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f46:	8b 45 10             	mov    0x10(%ebp),%eax
  801f49:	eb 05                	jmp    801f50 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    

00801f58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	57                   	push   %edi
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 18             	sub    $0x18,%esp
  801f61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f64:	57                   	push   %edi
  801f65:	e8 35 f2 ff ff       	call   80119f <fd2data>
  801f6a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f74:	eb 3d                	jmp    801fb3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f76:	85 db                	test   %ebx,%ebx
  801f78:	74 04                	je     801f7e <devpipe_read+0x26>
				return i;
  801f7a:	89 d8                	mov    %ebx,%eax
  801f7c:	eb 44                	jmp    801fc2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f7e:	89 f2                	mov    %esi,%edx
  801f80:	89 f8                	mov    %edi,%eax
  801f82:	e8 e5 fe ff ff       	call   801e6c <_pipeisclosed>
  801f87:	85 c0                	test   %eax,%eax
  801f89:	75 32                	jne    801fbd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f8b:	e8 8e ef ff ff       	call   800f1e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f90:	8b 06                	mov    (%esi),%eax
  801f92:	3b 46 04             	cmp    0x4(%esi),%eax
  801f95:	74 df                	je     801f76 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f97:	99                   	cltd   
  801f98:	c1 ea 1b             	shr    $0x1b,%edx
  801f9b:	01 d0                	add    %edx,%eax
  801f9d:	83 e0 1f             	and    $0x1f,%eax
  801fa0:	29 d0                	sub    %edx,%eax
  801fa2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801faa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb0:	83 c3 01             	add    $0x1,%ebx
  801fb3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fb6:	75 d8                	jne    801f90 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbb:	eb 05                	jmp    801fc2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fbd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc5:	5b                   	pop    %ebx
  801fc6:	5e                   	pop    %esi
  801fc7:	5f                   	pop    %edi
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    

00801fca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	56                   	push   %esi
  801fce:	53                   	push   %ebx
  801fcf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd5:	50                   	push   %eax
  801fd6:	e8 db f1 ff ff       	call   8011b6 <fd_alloc>
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	89 c2                	mov    %eax,%edx
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	0f 88 2c 01 00 00    	js     802114 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe8:	83 ec 04             	sub    $0x4,%esp
  801feb:	68 07 04 00 00       	push   $0x407
  801ff0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff3:	6a 00                	push   $0x0
  801ff5:	e8 43 ef ff ff       	call   800f3d <sys_page_alloc>
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	89 c2                	mov    %eax,%edx
  801fff:	85 c0                	test   %eax,%eax
  802001:	0f 88 0d 01 00 00    	js     802114 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802007:	83 ec 0c             	sub    $0xc,%esp
  80200a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80200d:	50                   	push   %eax
  80200e:	e8 a3 f1 ff ff       	call   8011b6 <fd_alloc>
  802013:	89 c3                	mov    %eax,%ebx
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 c0                	test   %eax,%eax
  80201a:	0f 88 e2 00 00 00    	js     802102 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802020:	83 ec 04             	sub    $0x4,%esp
  802023:	68 07 04 00 00       	push   $0x407
  802028:	ff 75 f0             	pushl  -0x10(%ebp)
  80202b:	6a 00                	push   $0x0
  80202d:	e8 0b ef ff ff       	call   800f3d <sys_page_alloc>
  802032:	89 c3                	mov    %eax,%ebx
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	85 c0                	test   %eax,%eax
  802039:	0f 88 c3 00 00 00    	js     802102 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80203f:	83 ec 0c             	sub    $0xc,%esp
  802042:	ff 75 f4             	pushl  -0xc(%ebp)
  802045:	e8 55 f1 ff ff       	call   80119f <fd2data>
  80204a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204c:	83 c4 0c             	add    $0xc,%esp
  80204f:	68 07 04 00 00       	push   $0x407
  802054:	50                   	push   %eax
  802055:	6a 00                	push   $0x0
  802057:	e8 e1 ee ff ff       	call   800f3d <sys_page_alloc>
  80205c:	89 c3                	mov    %eax,%ebx
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	85 c0                	test   %eax,%eax
  802063:	0f 88 89 00 00 00    	js     8020f2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802069:	83 ec 0c             	sub    $0xc,%esp
  80206c:	ff 75 f0             	pushl  -0x10(%ebp)
  80206f:	e8 2b f1 ff ff       	call   80119f <fd2data>
  802074:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80207b:	50                   	push   %eax
  80207c:	6a 00                	push   $0x0
  80207e:	56                   	push   %esi
  80207f:	6a 00                	push   $0x0
  802081:	e8 fa ee ff ff       	call   800f80 <sys_page_map>
  802086:	89 c3                	mov    %eax,%ebx
  802088:	83 c4 20             	add    $0x20,%esp
  80208b:	85 c0                	test   %eax,%eax
  80208d:	78 55                	js     8020e4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80208f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802095:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802098:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80209a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b9:	83 ec 0c             	sub    $0xc,%esp
  8020bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020bf:	e8 cb f0 ff ff       	call   80118f <fd2num>
  8020c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c9:	83 c4 04             	add    $0x4,%esp
  8020cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8020cf:	e8 bb f0 ff ff       	call   80118f <fd2num>
  8020d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e2:	eb 30                	jmp    802114 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020e4:	83 ec 08             	sub    $0x8,%esp
  8020e7:	56                   	push   %esi
  8020e8:	6a 00                	push   $0x0
  8020ea:	e8 d3 ee ff ff       	call   800fc2 <sys_page_unmap>
  8020ef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020f2:	83 ec 08             	sub    $0x8,%esp
  8020f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f8:	6a 00                	push   $0x0
  8020fa:	e8 c3 ee ff ff       	call   800fc2 <sys_page_unmap>
  8020ff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802102:	83 ec 08             	sub    $0x8,%esp
  802105:	ff 75 f4             	pushl  -0xc(%ebp)
  802108:	6a 00                	push   $0x0
  80210a:	e8 b3 ee ff ff       	call   800fc2 <sys_page_unmap>
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802114:	89 d0                	mov    %edx,%eax
  802116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802119:	5b                   	pop    %ebx
  80211a:	5e                   	pop    %esi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802123:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802126:	50                   	push   %eax
  802127:	ff 75 08             	pushl  0x8(%ebp)
  80212a:	e8 d6 f0 ff ff       	call   801205 <fd_lookup>
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	85 c0                	test   %eax,%eax
  802134:	78 18                	js     80214e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802136:	83 ec 0c             	sub    $0xc,%esp
  802139:	ff 75 f4             	pushl  -0xc(%ebp)
  80213c:	e8 5e f0 ff ff       	call   80119f <fd2data>
	return _pipeisclosed(fd, p);
  802141:	89 c2                	mov    %eax,%edx
  802143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802146:	e8 21 fd ff ff       	call   801e6c <_pipeisclosed>
  80214b:	83 c4 10             	add    $0x10,%esp
}
  80214e:	c9                   	leave  
  80214f:	c3                   	ret    

00802150 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802153:	b8 00 00 00 00       	mov    $0x0,%eax
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    

0080215a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802160:	68 67 2c 80 00       	push   $0x802c67
  802165:	ff 75 0c             	pushl  0xc(%ebp)
  802168:	e8 cd e9 ff ff       	call   800b3a <strcpy>
	return 0;
}
  80216d:	b8 00 00 00 00       	mov    $0x0,%eax
  802172:	c9                   	leave  
  802173:	c3                   	ret    

00802174 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802174:	55                   	push   %ebp
  802175:	89 e5                	mov    %esp,%ebp
  802177:	57                   	push   %edi
  802178:	56                   	push   %esi
  802179:	53                   	push   %ebx
  80217a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802180:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802185:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80218b:	eb 2d                	jmp    8021ba <devcons_write+0x46>
		m = n - tot;
  80218d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802190:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802192:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802195:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80219a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80219d:	83 ec 04             	sub    $0x4,%esp
  8021a0:	53                   	push   %ebx
  8021a1:	03 45 0c             	add    0xc(%ebp),%eax
  8021a4:	50                   	push   %eax
  8021a5:	57                   	push   %edi
  8021a6:	e8 21 eb ff ff       	call   800ccc <memmove>
		sys_cputs(buf, m);
  8021ab:	83 c4 08             	add    $0x8,%esp
  8021ae:	53                   	push   %ebx
  8021af:	57                   	push   %edi
  8021b0:	e8 cc ec ff ff       	call   800e81 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b5:	01 de                	add    %ebx,%esi
  8021b7:	83 c4 10             	add    $0x10,%esp
  8021ba:	89 f0                	mov    %esi,%eax
  8021bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021bf:	72 cc                	jb     80218d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    

008021c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	83 ec 08             	sub    $0x8,%esp
  8021cf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d8:	74 2a                	je     802204 <devcons_read+0x3b>
  8021da:	eb 05                	jmp    8021e1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021dc:	e8 3d ed ff ff       	call   800f1e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021e1:	e8 b9 ec ff ff       	call   800e9f <sys_cgetc>
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	74 f2                	je     8021dc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	78 16                	js     802204 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ee:	83 f8 04             	cmp    $0x4,%eax
  8021f1:	74 0c                	je     8021ff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f6:	88 02                	mov    %al,(%edx)
	return 1;
  8021f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fd:	eb 05                	jmp    802204 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802204:	c9                   	leave  
  802205:	c3                   	ret    

00802206 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80220c:	8b 45 08             	mov    0x8(%ebp),%eax
  80220f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802212:	6a 01                	push   $0x1
  802214:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802217:	50                   	push   %eax
  802218:	e8 64 ec ff ff       	call   800e81 <sys_cputs>
}
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	c9                   	leave  
  802221:	c3                   	ret    

00802222 <getchar>:

int
getchar(void)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802228:	6a 01                	push   $0x1
  80222a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80222d:	50                   	push   %eax
  80222e:	6a 00                	push   $0x0
  802230:	e8 36 f2 ff ff       	call   80146b <read>
	if (r < 0)
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	85 c0                	test   %eax,%eax
  80223a:	78 0f                	js     80224b <getchar+0x29>
		return r;
	if (r < 1)
  80223c:	85 c0                	test   %eax,%eax
  80223e:	7e 06                	jle    802246 <getchar+0x24>
		return -E_EOF;
	return c;
  802240:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802244:	eb 05                	jmp    80224b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802246:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802253:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802256:	50                   	push   %eax
  802257:	ff 75 08             	pushl  0x8(%ebp)
  80225a:	e8 a6 ef ff ff       	call   801205 <fd_lookup>
  80225f:	83 c4 10             	add    $0x10,%esp
  802262:	85 c0                	test   %eax,%eax
  802264:	78 11                	js     802277 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802269:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80226f:	39 10                	cmp    %edx,(%eax)
  802271:	0f 94 c0             	sete   %al
  802274:	0f b6 c0             	movzbl %al,%eax
}
  802277:	c9                   	leave  
  802278:	c3                   	ret    

00802279 <opencons>:

int
opencons(void)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80227f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802282:	50                   	push   %eax
  802283:	e8 2e ef ff ff       	call   8011b6 <fd_alloc>
  802288:	83 c4 10             	add    $0x10,%esp
		return r;
  80228b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80228d:	85 c0                	test   %eax,%eax
  80228f:	78 3e                	js     8022cf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802291:	83 ec 04             	sub    $0x4,%esp
  802294:	68 07 04 00 00       	push   $0x407
  802299:	ff 75 f4             	pushl  -0xc(%ebp)
  80229c:	6a 00                	push   $0x0
  80229e:	e8 9a ec ff ff       	call   800f3d <sys_page_alloc>
  8022a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a8:	85 c0                	test   %eax,%eax
  8022aa:	78 23                	js     8022cf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022c1:	83 ec 0c             	sub    $0xc,%esp
  8022c4:	50                   	push   %eax
  8022c5:	e8 c5 ee ff ff       	call   80118f <fd2num>
  8022ca:	89 c2                	mov    %eax,%edx
  8022cc:	83 c4 10             	add    $0x10,%esp
}
  8022cf:	89 d0                	mov    %edx,%eax
  8022d1:	c9                   	leave  
  8022d2:	c3                   	ret    

008022d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	56                   	push   %esi
  8022d7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022d8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022db:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022e1:	e8 19 ec ff ff       	call   800eff <sys_getenvid>
  8022e6:	83 ec 0c             	sub    $0xc,%esp
  8022e9:	ff 75 0c             	pushl  0xc(%ebp)
  8022ec:	ff 75 08             	pushl  0x8(%ebp)
  8022ef:	56                   	push   %esi
  8022f0:	50                   	push   %eax
  8022f1:	68 74 2c 80 00       	push   $0x802c74
  8022f6:	e8 ba e2 ff ff       	call   8005b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022fb:	83 c4 18             	add    $0x18,%esp
  8022fe:	53                   	push   %ebx
  8022ff:	ff 75 10             	pushl  0x10(%ebp)
  802302:	e8 5d e2 ff ff       	call   800564 <vcprintf>
	cprintf("\n");
  802307:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  80230e:	e8 a2 e2 ff ff       	call   8005b5 <cprintf>
  802313:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802316:	cc                   	int3   
  802317:	eb fd                	jmp    802316 <_panic+0x43>

00802319 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802319:	55                   	push   %ebp
  80231a:	89 e5                	mov    %esp,%ebp
  80231c:	56                   	push   %esi
  80231d:	53                   	push   %ebx
  80231e:	8b 75 08             	mov    0x8(%ebp),%esi
  802321:	8b 45 0c             	mov    0xc(%ebp),%eax
  802324:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802327:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802329:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80232e:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802331:	83 ec 0c             	sub    $0xc,%esp
  802334:	50                   	push   %eax
  802335:	e8 b3 ed ff ff       	call   8010ed <sys_ipc_recv>

	if (from_env_store != NULL)
  80233a:	83 c4 10             	add    $0x10,%esp
  80233d:	85 f6                	test   %esi,%esi
  80233f:	74 14                	je     802355 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802341:	ba 00 00 00 00       	mov    $0x0,%edx
  802346:	85 c0                	test   %eax,%eax
  802348:	78 09                	js     802353 <ipc_recv+0x3a>
  80234a:	8b 15 18 40 80 00    	mov    0x804018,%edx
  802350:	8b 52 74             	mov    0x74(%edx),%edx
  802353:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802355:	85 db                	test   %ebx,%ebx
  802357:	74 14                	je     80236d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802359:	ba 00 00 00 00       	mov    $0x0,%edx
  80235e:	85 c0                	test   %eax,%eax
  802360:	78 09                	js     80236b <ipc_recv+0x52>
  802362:	8b 15 18 40 80 00    	mov    0x804018,%edx
  802368:	8b 52 78             	mov    0x78(%edx),%edx
  80236b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 08                	js     802379 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802371:	a1 18 40 80 00       	mov    0x804018,%eax
  802376:	8b 40 70             	mov    0x70(%eax),%eax
}
  802379:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5e                   	pop    %esi
  80237e:	5d                   	pop    %ebp
  80237f:	c3                   	ret    

00802380 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	57                   	push   %edi
  802384:	56                   	push   %esi
  802385:	53                   	push   %ebx
  802386:	83 ec 0c             	sub    $0xc,%esp
  802389:	8b 7d 08             	mov    0x8(%ebp),%edi
  80238c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80238f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802392:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802394:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802399:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80239c:	ff 75 14             	pushl  0x14(%ebp)
  80239f:	53                   	push   %ebx
  8023a0:	56                   	push   %esi
  8023a1:	57                   	push   %edi
  8023a2:	e8 23 ed ff ff       	call   8010ca <sys_ipc_try_send>

		if (err < 0) {
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	79 1e                	jns    8023cc <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8023ae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023b1:	75 07                	jne    8023ba <ipc_send+0x3a>
				sys_yield();
  8023b3:	e8 66 eb ff ff       	call   800f1e <sys_yield>
  8023b8:	eb e2                	jmp    80239c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8023ba:	50                   	push   %eax
  8023bb:	68 98 2c 80 00       	push   $0x802c98
  8023c0:	6a 49                	push   $0x49
  8023c2:	68 a5 2c 80 00       	push   $0x802ca5
  8023c7:	e8 07 ff ff ff       	call   8022d3 <_panic>
		}

	} while (err < 0);

}
  8023cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023cf:	5b                   	pop    %ebx
  8023d0:	5e                   	pop    %esi
  8023d1:	5f                   	pop    %edi
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    

008023d4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023df:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023e2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023e8:	8b 52 50             	mov    0x50(%edx),%edx
  8023eb:	39 ca                	cmp    %ecx,%edx
  8023ed:	75 0d                	jne    8023fc <ipc_find_env+0x28>
			return envs[i].env_id;
  8023ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023f7:	8b 40 48             	mov    0x48(%eax),%eax
  8023fa:	eb 0f                	jmp    80240b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023fc:	83 c0 01             	add    $0x1,%eax
  8023ff:	3d 00 04 00 00       	cmp    $0x400,%eax
  802404:	75 d9                	jne    8023df <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802406:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    

0080240d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802413:	89 d0                	mov    %edx,%eax
  802415:	c1 e8 16             	shr    $0x16,%eax
  802418:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80241f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802424:	f6 c1 01             	test   $0x1,%cl
  802427:	74 1d                	je     802446 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802429:	c1 ea 0c             	shr    $0xc,%edx
  80242c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802433:	f6 c2 01             	test   $0x1,%dl
  802436:	74 0e                	je     802446 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802438:	c1 ea 0c             	shr    $0xc,%edx
  80243b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802442:	ef 
  802443:	0f b7 c0             	movzwl %ax,%eax
}
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	66 90                	xchg   %ax,%ax
  80244a:	66 90                	xchg   %ax,%ax
  80244c:	66 90                	xchg   %ax,%ax
  80244e:	66 90                	xchg   %ax,%ax

00802450 <__udivdi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	53                   	push   %ebx
  802454:	83 ec 1c             	sub    $0x1c,%esp
  802457:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80245b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80245f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802463:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802467:	85 f6                	test   %esi,%esi
  802469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80246d:	89 ca                	mov    %ecx,%edx
  80246f:	89 f8                	mov    %edi,%eax
  802471:	75 3d                	jne    8024b0 <__udivdi3+0x60>
  802473:	39 cf                	cmp    %ecx,%edi
  802475:	0f 87 c5 00 00 00    	ja     802540 <__udivdi3+0xf0>
  80247b:	85 ff                	test   %edi,%edi
  80247d:	89 fd                	mov    %edi,%ebp
  80247f:	75 0b                	jne    80248c <__udivdi3+0x3c>
  802481:	b8 01 00 00 00       	mov    $0x1,%eax
  802486:	31 d2                	xor    %edx,%edx
  802488:	f7 f7                	div    %edi
  80248a:	89 c5                	mov    %eax,%ebp
  80248c:	89 c8                	mov    %ecx,%eax
  80248e:	31 d2                	xor    %edx,%edx
  802490:	f7 f5                	div    %ebp
  802492:	89 c1                	mov    %eax,%ecx
  802494:	89 d8                	mov    %ebx,%eax
  802496:	89 cf                	mov    %ecx,%edi
  802498:	f7 f5                	div    %ebp
  80249a:	89 c3                	mov    %eax,%ebx
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	89 fa                	mov    %edi,%edx
  8024a0:	83 c4 1c             	add    $0x1c,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
  8024a8:	90                   	nop
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	39 ce                	cmp    %ecx,%esi
  8024b2:	77 74                	ja     802528 <__udivdi3+0xd8>
  8024b4:	0f bd fe             	bsr    %esi,%edi
  8024b7:	83 f7 1f             	xor    $0x1f,%edi
  8024ba:	0f 84 98 00 00 00    	je     802558 <__udivdi3+0x108>
  8024c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	89 c5                	mov    %eax,%ebp
  8024c9:	29 fb                	sub    %edi,%ebx
  8024cb:	d3 e6                	shl    %cl,%esi
  8024cd:	89 d9                	mov    %ebx,%ecx
  8024cf:	d3 ed                	shr    %cl,%ebp
  8024d1:	89 f9                	mov    %edi,%ecx
  8024d3:	d3 e0                	shl    %cl,%eax
  8024d5:	09 ee                	or     %ebp,%esi
  8024d7:	89 d9                	mov    %ebx,%ecx
  8024d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024dd:	89 d5                	mov    %edx,%ebp
  8024df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024e3:	d3 ed                	shr    %cl,%ebp
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e2                	shl    %cl,%edx
  8024e9:	89 d9                	mov    %ebx,%ecx
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	09 c2                	or     %eax,%edx
  8024ef:	89 d0                	mov    %edx,%eax
  8024f1:	89 ea                	mov    %ebp,%edx
  8024f3:	f7 f6                	div    %esi
  8024f5:	89 d5                	mov    %edx,%ebp
  8024f7:	89 c3                	mov    %eax,%ebx
  8024f9:	f7 64 24 0c          	mull   0xc(%esp)
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	72 10                	jb     802511 <__udivdi3+0xc1>
  802501:	8b 74 24 08          	mov    0x8(%esp),%esi
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e6                	shl    %cl,%esi
  802509:	39 c6                	cmp    %eax,%esi
  80250b:	73 07                	jae    802514 <__udivdi3+0xc4>
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	75 03                	jne    802514 <__udivdi3+0xc4>
  802511:	83 eb 01             	sub    $0x1,%ebx
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 d8                	mov    %ebx,%eax
  802518:	89 fa                	mov    %edi,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	31 ff                	xor    %edi,%edi
  80252a:	31 db                	xor    %ebx,%ebx
  80252c:	89 d8                	mov    %ebx,%eax
  80252e:	89 fa                	mov    %edi,%edx
  802530:	83 c4 1c             	add    $0x1c,%esp
  802533:	5b                   	pop    %ebx
  802534:	5e                   	pop    %esi
  802535:	5f                   	pop    %edi
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	90                   	nop
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d8                	mov    %ebx,%eax
  802542:	f7 f7                	div    %edi
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 c3                	mov    %eax,%ebx
  802548:	89 d8                	mov    %ebx,%eax
  80254a:	89 fa                	mov    %edi,%edx
  80254c:	83 c4 1c             	add    $0x1c,%esp
  80254f:	5b                   	pop    %ebx
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
  802554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802558:	39 ce                	cmp    %ecx,%esi
  80255a:	72 0c                	jb     802568 <__udivdi3+0x118>
  80255c:	31 db                	xor    %ebx,%ebx
  80255e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802562:	0f 87 34 ff ff ff    	ja     80249c <__udivdi3+0x4c>
  802568:	bb 01 00 00 00       	mov    $0x1,%ebx
  80256d:	e9 2a ff ff ff       	jmp    80249c <__udivdi3+0x4c>
  802572:	66 90                	xchg   %ax,%ax
  802574:	66 90                	xchg   %ax,%ax
  802576:	66 90                	xchg   %ax,%ax
  802578:	66 90                	xchg   %ax,%ax
  80257a:	66 90                	xchg   %ax,%ax
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__umoddi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80258b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80258f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 d2                	test   %edx,%edx
  802599:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 f3                	mov    %esi,%ebx
  8025a3:	89 3c 24             	mov    %edi,(%esp)
  8025a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025aa:	75 1c                	jne    8025c8 <__umoddi3+0x48>
  8025ac:	39 f7                	cmp    %esi,%edi
  8025ae:	76 50                	jbe    802600 <__umoddi3+0x80>
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	f7 f7                	div    %edi
  8025b6:	89 d0                	mov    %edx,%eax
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	83 c4 1c             	add    $0x1c,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	39 f2                	cmp    %esi,%edx
  8025ca:	89 d0                	mov    %edx,%eax
  8025cc:	77 52                	ja     802620 <__umoddi3+0xa0>
  8025ce:	0f bd ea             	bsr    %edx,%ebp
  8025d1:	83 f5 1f             	xor    $0x1f,%ebp
  8025d4:	75 5a                	jne    802630 <__umoddi3+0xb0>
  8025d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025da:	0f 82 e0 00 00 00    	jb     8026c0 <__umoddi3+0x140>
  8025e0:	39 0c 24             	cmp    %ecx,(%esp)
  8025e3:	0f 86 d7 00 00 00    	jbe    8026c0 <__umoddi3+0x140>
  8025e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025f1:	83 c4 1c             	add    $0x1c,%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	85 ff                	test   %edi,%edi
  802602:	89 fd                	mov    %edi,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x91>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f7                	div    %edi
  80260f:	89 c5                	mov    %eax,%ebp
  802611:	89 f0                	mov    %esi,%eax
  802613:	31 d2                	xor    %edx,%edx
  802615:	f7 f5                	div    %ebp
  802617:	89 c8                	mov    %ecx,%eax
  802619:	f7 f5                	div    %ebp
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	eb 99                	jmp    8025b8 <__umoddi3+0x38>
  80261f:	90                   	nop
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	83 c4 1c             	add    $0x1c,%esp
  802627:	5b                   	pop    %ebx
  802628:	5e                   	pop    %esi
  802629:	5f                   	pop    %edi
  80262a:	5d                   	pop    %ebp
  80262b:	c3                   	ret    
  80262c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802630:	8b 34 24             	mov    (%esp),%esi
  802633:	bf 20 00 00 00       	mov    $0x20,%edi
  802638:	89 e9                	mov    %ebp,%ecx
  80263a:	29 ef                	sub    %ebp,%edi
  80263c:	d3 e0                	shl    %cl,%eax
  80263e:	89 f9                	mov    %edi,%ecx
  802640:	89 f2                	mov    %esi,%edx
  802642:	d3 ea                	shr    %cl,%edx
  802644:	89 e9                	mov    %ebp,%ecx
  802646:	09 c2                	or     %eax,%edx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 14 24             	mov    %edx,(%esp)
  80264d:	89 f2                	mov    %esi,%edx
  80264f:	d3 e2                	shl    %cl,%edx
  802651:	89 f9                	mov    %edi,%ecx
  802653:	89 54 24 04          	mov    %edx,0x4(%esp)
  802657:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80265b:	d3 e8                	shr    %cl,%eax
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	89 c6                	mov    %eax,%esi
  802661:	d3 e3                	shl    %cl,%ebx
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 d0                	mov    %edx,%eax
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	09 d8                	or     %ebx,%eax
  80266d:	89 d3                	mov    %edx,%ebx
  80266f:	89 f2                	mov    %esi,%edx
  802671:	f7 34 24             	divl   (%esp)
  802674:	89 d6                	mov    %edx,%esi
  802676:	d3 e3                	shl    %cl,%ebx
  802678:	f7 64 24 04          	mull   0x4(%esp)
  80267c:	39 d6                	cmp    %edx,%esi
  80267e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802682:	89 d1                	mov    %edx,%ecx
  802684:	89 c3                	mov    %eax,%ebx
  802686:	72 08                	jb     802690 <__umoddi3+0x110>
  802688:	75 11                	jne    80269b <__umoddi3+0x11b>
  80268a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80268e:	73 0b                	jae    80269b <__umoddi3+0x11b>
  802690:	2b 44 24 04          	sub    0x4(%esp),%eax
  802694:	1b 14 24             	sbb    (%esp),%edx
  802697:	89 d1                	mov    %edx,%ecx
  802699:	89 c3                	mov    %eax,%ebx
  80269b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80269f:	29 da                	sub    %ebx,%edx
  8026a1:	19 ce                	sbb    %ecx,%esi
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 f0                	mov    %esi,%eax
  8026a7:	d3 e0                	shl    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	d3 ea                	shr    %cl,%edx
  8026ad:	89 e9                	mov    %ebp,%ecx
  8026af:	d3 ee                	shr    %cl,%esi
  8026b1:	09 d0                	or     %edx,%eax
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	83 c4 1c             	add    $0x1c,%esp
  8026b8:	5b                   	pop    %ebx
  8026b9:	5e                   	pop    %esi
  8026ba:	5f                   	pop    %edi
  8026bb:	5d                   	pop    %ebp
  8026bc:	c3                   	ret    
  8026bd:	8d 76 00             	lea    0x0(%esi),%esi
  8026c0:	29 f9                	sub    %edi,%ecx
  8026c2:	19 d6                	sbb    %edx,%esi
  8026c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026cc:	e9 18 ff ff ff       	jmp    8025e9 <__umoddi3+0x69>
