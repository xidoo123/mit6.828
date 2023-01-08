
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 79 04 00 00       	call   8004aa <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 80 26 80 00       	push   $0x802680
  80003f:	e8 59 05 00 00       	call   80059d <cprintf>
	exit();
  800044:	e8 a7 04 00 00       	call   8004f0 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 58             	sub    $0x58,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  800057:	68 84 26 80 00       	push   $0x802684
  80005c:	e8 3c 05 00 00       	call   80059d <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800061:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  800068:	e8 0b 04 00 00       	call   800478 <inet_addr>
  80006d:	83 c4 0c             	add    $0xc,%esp
  800070:	50                   	push   %eax
  800071:	68 94 26 80 00       	push   $0x802694
  800076:	68 9e 26 80 00       	push   $0x80269e
  80007b:	e8 1d 05 00 00       	call   80059d <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	6a 06                	push   $0x6
  800085:	6a 01                	push   $0x1
  800087:	6a 02                	push   $0x2
  800089:	e8 94 1a 00 00       	call   801b22 <socket>
  80008e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 0a                	jns    8000a2 <umain+0x54>
		die("Failed to create socket");
  800098:	b8 b3 26 80 00       	mov    $0x8026b3,%eax
  80009d:	e8 91 ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	68 cb 26 80 00       	push   $0x8026cb
  8000aa:	e8 ee 04 00 00       	call   80059d <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 10                	push   $0x10
  8000b4:	6a 00                	push   $0x0
  8000b6:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b9:	53                   	push   %ebx
  8000ba:	e8 a8 0b 00 00       	call   800c67 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000bf:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000c3:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  8000ca:	e8 a9 03 00 00       	call   800478 <inet_addr>
  8000cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000d2:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000d9:	e8 81 01 00 00       	call   80025f <htons>
  8000de:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  8000e2:	c7 04 24 da 26 80 00 	movl   $0x8026da,(%esp)
  8000e9:	e8 af 04 00 00       	call   80059d <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000ee:	83 c4 0c             	add    $0xc,%esp
  8000f1:	6a 10                	push   $0x10
  8000f3:	53                   	push   %ebx
  8000f4:	ff 75 b4             	pushl  -0x4c(%ebp)
  8000f7:	e8 dd 19 00 00       	call   801ad9 <connect>
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 c0                	test   %eax,%eax
  800101:	79 0a                	jns    80010d <umain+0xbf>
		die("Failed to connect with server");
  800103:	b8 f7 26 80 00       	mov    $0x8026f7,%eax
  800108:	e8 26 ff ff ff       	call   800033 <die>

	cprintf("connected to server\n");
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	68 15 27 80 00       	push   $0x802715
  800115:	e8 83 04 00 00       	call   80059d <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 00 30 80 00    	pushl  0x803000
  800123:	e8 c1 09 00 00       	call   800ae9 <strlen>
  800128:	89 c7                	mov    %eax,%edi
  80012a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80012d:	83 c4 0c             	add    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	ff 35 00 30 80 00    	pushl  0x803000
  800137:	ff 75 b4             	pushl  -0x4c(%ebp)
  80013a:	e8 ac 13 00 00       	call   8014eb <write>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	39 c7                	cmp    %eax,%edi
  800144:	74 0a                	je     800150 <umain+0x102>
		die("Mismatch in number of sent bytes");
  800146:	b8 44 27 80 00       	mov    $0x802744,%eax
  80014b:	e8 e3 fe ff ff       	call   800033 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	68 2a 27 80 00       	push   $0x80272a
  800158:	e8 40 04 00 00       	call   80059d <cprintf>
	while (received < echolen) {
  80015d:	83 c4 10             	add    $0x10,%esp
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800160:	be 00 00 00 00       	mov    $0x0,%esi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800165:	8d 7d b8             	lea    -0x48(%ebp),%edi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800168:	eb 34                	jmp    80019e <umain+0x150>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80016a:	83 ec 04             	sub    $0x4,%esp
  80016d:	6a 1f                	push   $0x1f
  80016f:	57                   	push   %edi
  800170:	ff 75 b4             	pushl  -0x4c(%ebp)
  800173:	e8 99 12 00 00       	call   801411 <read>
  800178:	89 c3                	mov    %eax,%ebx
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	7f 0a                	jg     80018b <umain+0x13d>
			die("Failed to receive bytes from server");
  800181:	b8 68 27 80 00       	mov    $0x802768,%eax
  800186:	e8 a8 fe ff ff       	call   800033 <die>
		}
		received += bytes;
  80018b:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  80018d:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	57                   	push   %edi
  800196:	e8 02 04 00 00       	call   80059d <cprintf>
  80019b:	83 c4 10             	add    $0x10,%esp
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  80019e:	39 75 b0             	cmp    %esi,-0x50(%ebp)
  8001a1:	77 c7                	ja     80016a <umain+0x11c>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 34 27 80 00       	push   $0x802734
  8001ab:	e8 ed 03 00 00       	call   80059d <cprintf>

	close(sock);
  8001b0:	83 c4 04             	add    $0x4,%esp
  8001b3:	ff 75 b4             	pushl  -0x4c(%ebp)
  8001b6:	e8 1a 11 00 00       	call   8012d5 <close>
}
  8001bb:	83 c4 10             	add    $0x10,%esp
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001d5:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001d8:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001df:	0f b6 0f             	movzbl (%edi),%ecx
  8001e2:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001e7:	0f b6 d9             	movzbl %cl,%ebx
  8001ea:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8001ed:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8001f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001f3:	66 c1 e8 0b          	shr    $0xb,%ax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001fc:	01 c0                	add    %eax,%eax
  8001fe:	29 c1                	sub    %eax,%ecx
  800200:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800202:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800204:	8d 72 01             	lea    0x1(%edx),%esi
  800207:	0f b6 d2             	movzbl %dl,%edx
  80020a:	83 c0 30             	add    $0x30,%eax
  80020d:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800211:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800213:	84 db                	test   %bl,%bl
  800215:	75 d0                	jne    8001e7 <inet_ntoa+0x21>
  800217:	c6 07 00             	movb   $0x0,(%edi)
  80021a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80021d:	eb 0d                	jmp    80022c <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  80021f:	0f b6 c2             	movzbl %dl,%eax
  800222:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800227:	88 01                	mov    %al,(%ecx)
  800229:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80022c:	83 ea 01             	sub    $0x1,%edx
  80022f:	80 fa ff             	cmp    $0xff,%dl
  800232:	75 eb                	jne    80021f <inet_ntoa+0x59>
  800234:	89 f0                	mov    %esi,%eax
  800236:	0f b6 f0             	movzbl %al,%esi
  800239:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  80023c:	8d 46 01             	lea    0x1(%esi),%eax
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  800245:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80024b:	39 c7                	cmp    %eax,%edi
  80024d:	75 90                	jne    8001df <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  80024f:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800252:	b8 00 40 80 00       	mov    $0x804000,%eax
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800262:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800266:	66 c1 c0 08          	rol    $0x8,%ax
}
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  return htons(n);
  80026f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800273:	66 c1 c0 08          	rol    $0x8,%ax
}
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  80027f:	89 d1                	mov    %edx,%ecx
  800281:	c1 e1 18             	shl    $0x18,%ecx
  800284:	89 d0                	mov    %edx,%eax
  800286:	c1 e8 18             	shr    $0x18,%eax
  800289:	09 c8                	or     %ecx,%eax
  80028b:	89 d1                	mov    %edx,%ecx
  80028d:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800293:	c1 e1 08             	shl    $0x8,%ecx
  800296:	09 c8                	or     %ecx,%eax
  800298:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80029e:	c1 ea 08             	shr    $0x8,%edx
  8002a1:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 20             	sub    $0x20,%esp
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002b1:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002b4:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002b7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002ba:	0f b6 ca             	movzbl %dl,%ecx
  8002bd:	83 e9 30             	sub    $0x30,%ecx
  8002c0:	83 f9 09             	cmp    $0x9,%ecx
  8002c3:	0f 87 94 01 00 00    	ja     80045d <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002c9:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002d0:	83 fa 30             	cmp    $0x30,%edx
  8002d3:	75 2b                	jne    800300 <inet_aton+0x5b>
      c = *++cp;
  8002d5:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002d9:	89 d1                	mov    %edx,%ecx
  8002db:	83 e1 df             	and    $0xffffffdf,%ecx
  8002de:	80 f9 58             	cmp    $0x58,%cl
  8002e1:	74 0f                	je     8002f2 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002e3:	83 c0 01             	add    $0x1,%eax
  8002e6:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8002e9:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8002f0:	eb 0e                	jmp    800300 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8002f2:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8002f6:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8002f9:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800300:	83 c0 01             	add    $0x1,%eax
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	eb 03                	jmp    80030d <inet_aton+0x68>
  80030a:	83 c0 01             	add    $0x1,%eax
  80030d:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800310:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800313:	0f b6 fa             	movzbl %dl,%edi
  800316:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800319:	83 f9 09             	cmp    $0x9,%ecx
  80031c:	77 0d                	ja     80032b <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  80031e:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800322:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800326:	0f be 10             	movsbl (%eax),%edx
  800329:	eb df                	jmp    80030a <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  80032b:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80032f:	75 32                	jne    800363 <inet_aton+0xbe>
  800331:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800334:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800337:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033a:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800340:	83 e9 41             	sub    $0x41,%ecx
  800343:	83 f9 05             	cmp    $0x5,%ecx
  800346:	77 1b                	ja     800363 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800348:	c1 e6 04             	shl    $0x4,%esi
  80034b:	83 c2 0a             	add    $0xa,%edx
  80034e:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800352:	19 c9                	sbb    %ecx,%ecx
  800354:	83 e1 20             	and    $0x20,%ecx
  800357:	83 c1 41             	add    $0x41,%ecx
  80035a:	29 ca                	sub    %ecx,%edx
  80035c:	09 d6                	or     %edx,%esi
        c = *++cp;
  80035e:	0f be 10             	movsbl (%eax),%edx
  800361:	eb a7                	jmp    80030a <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800363:	83 fa 2e             	cmp    $0x2e,%edx
  800366:	75 23                	jne    80038b <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	8d 7d f0             	lea    -0x10(%ebp),%edi
  80036e:	39 f8                	cmp    %edi,%eax
  800370:	0f 84 ee 00 00 00    	je     800464 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800376:	83 c0 04             	add    $0x4,%eax
  800379:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80037c:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  80037f:	8d 43 01             	lea    0x1(%ebx),%eax
  800382:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800386:	e9 2f ff ff ff       	jmp    8002ba <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 25                	je     8003b4 <inet_aton+0x10f>
  80038f:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800397:	83 f9 5f             	cmp    $0x5f,%ecx
  80039a:	0f 87 d0 00 00 00    	ja     800470 <inet_aton+0x1cb>
  8003a0:	83 fa 20             	cmp    $0x20,%edx
  8003a3:	74 0f                	je     8003b4 <inet_aton+0x10f>
  8003a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a8:	83 ea 09             	sub    $0x9,%edx
  8003ab:	83 fa 04             	cmp    $0x4,%edx
  8003ae:	0f 87 bc 00 00 00    	ja     800470 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003ba:	29 c2                	sub    %eax,%edx
  8003bc:	c1 fa 02             	sar    $0x2,%edx
  8003bf:	83 c2 01             	add    $0x1,%edx
  8003c2:	83 fa 02             	cmp    $0x2,%edx
  8003c5:	74 20                	je     8003e7 <inet_aton+0x142>
  8003c7:	83 fa 02             	cmp    $0x2,%edx
  8003ca:	7f 0f                	jg     8003db <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	0f 84 97 00 00 00    	je     800470 <inet_aton+0x1cb>
  8003d9:	eb 67                	jmp    800442 <inet_aton+0x19d>
  8003db:	83 fa 03             	cmp    $0x3,%edx
  8003de:	74 1e                	je     8003fe <inet_aton+0x159>
  8003e0:	83 fa 04             	cmp    $0x4,%edx
  8003e3:	74 38                	je     80041d <inet_aton+0x178>
  8003e5:	eb 5b                	jmp    800442 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8003ec:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8003f2:	77 7c                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8003f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f7:	c1 e0 18             	shl    $0x18,%eax
  8003fa:	09 c6                	or     %eax,%esi
    break;
  8003fc:	eb 44                	jmp    800442 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800403:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800409:	77 65                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	c1 e2 18             	shl    $0x18,%edx
  800411:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800414:	c1 e0 10             	shl    $0x10,%eax
  800417:	09 d0                	or     %edx,%eax
  800419:	09 c6                	or     %eax,%esi
    break;
  80041b:	eb 25                	jmp    800442 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800422:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800428:	77 46                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80042a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042d:	c1 e2 18             	shl    $0x18,%edx
  800430:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800433:	c1 e0 10             	shl    $0x10,%eax
  800436:	09 c2                	or     %eax,%edx
  800438:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80043b:	c1 e0 08             	shl    $0x8,%eax
  80043e:	09 d0                	or     %edx,%eax
  800440:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800442:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800446:	74 23                	je     80046b <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800448:	56                   	push   %esi
  800449:	e8 2b fe ff ff       	call   800279 <htonl>
  80044e:	83 c4 04             	add    $0x4,%esp
  800451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800454:	89 03                	mov    %eax,(%ebx)
  return (1);
  800456:	b8 01 00 00 00       	mov    $0x1,%eax
  80045b:	eb 13                	jmp    800470 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	eb 0c                	jmp    800470 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800464:	b8 00 00 00 00       	mov    $0x0,%eax
  800469:	eb 05                	jmp    800470 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80046b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800473:	5b                   	pop    %ebx
  800474:	5e                   	pop    %esi
  800475:	5f                   	pop    %edi
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    

00800478 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80047e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800481:	50                   	push   %eax
  800482:	ff 75 08             	pushl  0x8(%ebp)
  800485:	e8 1b fe ff ff       	call   8002a5 <inet_aton>
  80048a:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80048d:	85 c0                	test   %eax,%eax
  80048f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800494:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    

0080049a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80049d:	ff 75 08             	pushl  0x8(%ebp)
  8004a0:	e8 d4 fd ff ff       	call   800279 <htonl>
  8004a5:	83 c4 04             	add    $0x4,%esp
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	56                   	push   %esi
  8004ae:	53                   	push   %ebx
  8004af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8004b5:	e8 2d 0a 00 00       	call   800ee7 <sys_getenvid>
  8004ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004c7:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004cc:	85 db                	test   %ebx,%ebx
  8004ce:	7e 07                	jle    8004d7 <libmain+0x2d>
		binaryname = argv[0];
  8004d0:	8b 06                	mov    (%esi),%eax
  8004d2:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
  8004dc:	e8 6d fb ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  8004e1:	e8 0a 00 00 00       	call   8004f0 <exit>
}
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ec:	5b                   	pop    %ebx
  8004ed:	5e                   	pop    %esi
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004f6:	e8 05 0e 00 00       	call   801300 <close_all>
	sys_env_destroy(0);
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	6a 00                	push   $0x0
  800500:	e8 a1 09 00 00       	call   800ea6 <sys_env_destroy>
}
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	c9                   	leave  
  800509:	c3                   	ret    

0080050a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	53                   	push   %ebx
  80050e:	83 ec 04             	sub    $0x4,%esp
  800511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800514:	8b 13                	mov    (%ebx),%edx
  800516:	8d 42 01             	lea    0x1(%edx),%eax
  800519:	89 03                	mov    %eax,(%ebx)
  80051b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80051e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800522:	3d ff 00 00 00       	cmp    $0xff,%eax
  800527:	75 1a                	jne    800543 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	68 ff 00 00 00       	push   $0xff
  800531:	8d 43 08             	lea    0x8(%ebx),%eax
  800534:	50                   	push   %eax
  800535:	e8 2f 09 00 00       	call   800e69 <sys_cputs>
		b->idx = 0;
  80053a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800540:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800543:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800555:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80055c:	00 00 00 
	b.cnt = 0;
  80055f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800566:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800569:	ff 75 0c             	pushl  0xc(%ebp)
  80056c:	ff 75 08             	pushl  0x8(%ebp)
  80056f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800575:	50                   	push   %eax
  800576:	68 0a 05 80 00       	push   $0x80050a
  80057b:	e8 54 01 00 00       	call   8006d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800580:	83 c4 08             	add    $0x8,%esp
  800583:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800589:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80058f:	50                   	push   %eax
  800590:	e8 d4 08 00 00       	call   800e69 <sys_cputs>

	return b.cnt;
}
  800595:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80059b:	c9                   	leave  
  80059c:	c3                   	ret    

0080059d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
  8005a0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005a6:	50                   	push   %eax
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 9d ff ff ff       	call   80054c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	57                   	push   %edi
  8005b5:	56                   	push   %esi
  8005b6:	53                   	push   %ebx
  8005b7:	83 ec 1c             	sub    $0x1c,%esp
  8005ba:	89 c7                	mov    %eax,%edi
  8005bc:	89 d6                	mov    %edx,%esi
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005d5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005d8:	39 d3                	cmp    %edx,%ebx
  8005da:	72 05                	jb     8005e1 <printnum+0x30>
  8005dc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005df:	77 45                	ja     800626 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005e1:	83 ec 0c             	sub    $0xc,%esp
  8005e4:	ff 75 18             	pushl  0x18(%ebp)
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005ed:	53                   	push   %ebx
  8005ee:	ff 75 10             	pushl  0x10(%ebp)
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8005fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800600:	e8 eb 1d 00 00       	call   8023f0 <__udivdi3>
  800605:	83 c4 18             	add    $0x18,%esp
  800608:	52                   	push   %edx
  800609:	50                   	push   %eax
  80060a:	89 f2                	mov    %esi,%edx
  80060c:	89 f8                	mov    %edi,%eax
  80060e:	e8 9e ff ff ff       	call   8005b1 <printnum>
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	eb 18                	jmp    800630 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	56                   	push   %esi
  80061c:	ff 75 18             	pushl  0x18(%ebp)
  80061f:	ff d7                	call   *%edi
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	eb 03                	jmp    800629 <printnum+0x78>
  800626:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800629:	83 eb 01             	sub    $0x1,%ebx
  80062c:	85 db                	test   %ebx,%ebx
  80062e:	7f e8                	jg     800618 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	83 ec 04             	sub    $0x4,%esp
  800637:	ff 75 e4             	pushl  -0x1c(%ebp)
  80063a:	ff 75 e0             	pushl  -0x20(%ebp)
  80063d:	ff 75 dc             	pushl  -0x24(%ebp)
  800640:	ff 75 d8             	pushl  -0x28(%ebp)
  800643:	e8 d8 1e 00 00       	call   802520 <__umoddi3>
  800648:	83 c4 14             	add    $0x14,%esp
  80064b:	0f be 80 96 27 80 00 	movsbl 0x802796(%eax),%eax
  800652:	50                   	push   %eax
  800653:	ff d7                	call   *%edi
}
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065b:	5b                   	pop    %ebx
  80065c:	5e                   	pop    %esi
  80065d:	5f                   	pop    %edi
  80065e:	5d                   	pop    %ebp
  80065f:	c3                   	ret    

00800660 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800663:	83 fa 01             	cmp    $0x1,%edx
  800666:	7e 0e                	jle    800676 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80066d:	89 08                	mov    %ecx,(%eax)
  80066f:	8b 02                	mov    (%edx),%eax
  800671:	8b 52 04             	mov    0x4(%edx),%edx
  800674:	eb 22                	jmp    800698 <getuint+0x38>
	else if (lflag)
  800676:	85 d2                	test   %edx,%edx
  800678:	74 10                	je     80068a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80067f:	89 08                	mov    %ecx,(%eax)
  800681:	8b 02                	mov    (%edx),%eax
  800683:	ba 00 00 00 00       	mov    $0x0,%edx
  800688:	eb 0e                	jmp    800698 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068f:	89 08                	mov    %ecx,(%eax)
  800691:	8b 02                	mov    (%edx),%eax
  800693:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006a4:	8b 10                	mov    (%eax),%edx
  8006a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006a9:	73 0a                	jae    8006b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ae:	89 08                	mov    %ecx,(%eax)
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	88 02                	mov    %al,(%edx)
}
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006c0:	50                   	push   %eax
  8006c1:	ff 75 10             	pushl  0x10(%ebp)
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	ff 75 08             	pushl  0x8(%ebp)
  8006ca:	e8 05 00 00 00       	call   8006d4 <vprintfmt>
	va_end(ap);
}
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	57                   	push   %edi
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	83 ec 2c             	sub    $0x2c,%esp
  8006dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006e6:	eb 12                	jmp    8006fa <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	0f 84 89 03 00 00    	je     800a79 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	53                   	push   %ebx
  8006f4:	50                   	push   %eax
  8006f5:	ff d6                	call   *%esi
  8006f7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006fa:	83 c7 01             	add    $0x1,%edi
  8006fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800701:	83 f8 25             	cmp    $0x25,%eax
  800704:	75 e2                	jne    8006e8 <vprintfmt+0x14>
  800706:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80070a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800711:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800718:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80071f:	ba 00 00 00 00       	mov    $0x0,%edx
  800724:	eb 07                	jmp    80072d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800729:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	8d 47 01             	lea    0x1(%edi),%eax
  800730:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800733:	0f b6 07             	movzbl (%edi),%eax
  800736:	0f b6 c8             	movzbl %al,%ecx
  800739:	83 e8 23             	sub    $0x23,%eax
  80073c:	3c 55                	cmp    $0x55,%al
  80073e:	0f 87 1a 03 00 00    	ja     800a5e <vprintfmt+0x38a>
  800744:	0f b6 c0             	movzbl %al,%eax
  800747:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
  80074e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800751:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800755:	eb d6                	jmp    80072d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
  80075f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800762:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800765:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800769:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80076c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80076f:	83 fa 09             	cmp    $0x9,%edx
  800772:	77 39                	ja     8007ad <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800774:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800777:	eb e9                	jmp    800762 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8d 48 04             	lea    0x4(%eax),%ecx
  80077f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800782:	8b 00                	mov    (%eax),%eax
  800784:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80078a:	eb 27                	jmp    8007b3 <vprintfmt+0xdf>
  80078c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078f:	85 c0                	test   %eax,%eax
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	0f 49 c8             	cmovns %eax,%ecx
  800799:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079f:	eb 8c                	jmp    80072d <vprintfmt+0x59>
  8007a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007ab:	eb 80                	jmp    80072d <vprintfmt+0x59>
  8007ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007b7:	0f 89 70 ff ff ff    	jns    80072d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ca:	e9 5e ff ff ff       	jmp    80072d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007cf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007d5:	e9 53 ff ff ff       	jmp    80072d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 50 04             	lea    0x4(%eax),%edx
  8007e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	ff 30                	pushl  (%eax)
  8007e9:	ff d6                	call   *%esi
			break;
  8007eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007f1:	e9 04 ff ff ff       	jmp    8006fa <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 04             	lea    0x4(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	99                   	cltd   
  800802:	31 d0                	xor    %edx,%eax
  800804:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800806:	83 f8 0f             	cmp    $0xf,%eax
  800809:	7f 0b                	jg     800816 <vprintfmt+0x142>
  80080b:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800812:	85 d2                	test   %edx,%edx
  800814:	75 18                	jne    80082e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800816:	50                   	push   %eax
  800817:	68 ae 27 80 00       	push   $0x8027ae
  80081c:	53                   	push   %ebx
  80081d:	56                   	push   %esi
  80081e:	e8 94 fe ff ff       	call   8006b7 <printfmt>
  800823:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800829:	e9 cc fe ff ff       	jmp    8006fa <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80082e:	52                   	push   %edx
  80082f:	68 75 2b 80 00       	push   $0x802b75
  800834:	53                   	push   %ebx
  800835:	56                   	push   %esi
  800836:	e8 7c fe ff ff       	call   8006b7 <printfmt>
  80083b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800841:	e9 b4 fe ff ff       	jmp    8006fa <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8d 50 04             	lea    0x4(%eax),%edx
  80084c:	89 55 14             	mov    %edx,0x14(%ebp)
  80084f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800851:	85 ff                	test   %edi,%edi
  800853:	b8 a7 27 80 00       	mov    $0x8027a7,%eax
  800858:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80085b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80085f:	0f 8e 94 00 00 00    	jle    8008f9 <vprintfmt+0x225>
  800865:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800869:	0f 84 98 00 00 00    	je     800907 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	ff 75 d0             	pushl  -0x30(%ebp)
  800875:	57                   	push   %edi
  800876:	e8 86 02 00 00       	call   800b01 <strnlen>
  80087b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80087e:	29 c1                	sub    %eax,%ecx
  800880:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800883:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800886:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80088a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80088d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800890:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800892:	eb 0f                	jmp    8008a3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	53                   	push   %ebx
  800898:	ff 75 e0             	pushl  -0x20(%ebp)
  80089b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089d:	83 ef 01             	sub    $0x1,%edi
  8008a0:	83 c4 10             	add    $0x10,%esp
  8008a3:	85 ff                	test   %edi,%edi
  8008a5:	7f ed                	jg     800894 <vprintfmt+0x1c0>
  8008a7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008aa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008ad:	85 c9                	test   %ecx,%ecx
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b4:	0f 49 c1             	cmovns %ecx,%eax
  8008b7:	29 c1                	sub    %eax,%ecx
  8008b9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008bc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008bf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008c2:	89 cb                	mov    %ecx,%ebx
  8008c4:	eb 4d                	jmp    800913 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008c6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ca:	74 1b                	je     8008e7 <vprintfmt+0x213>
  8008cc:	0f be c0             	movsbl %al,%eax
  8008cf:	83 e8 20             	sub    $0x20,%eax
  8008d2:	83 f8 5e             	cmp    $0x5e,%eax
  8008d5:	76 10                	jbe    8008e7 <vprintfmt+0x213>
					putch('?', putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	ff 75 0c             	pushl  0xc(%ebp)
  8008dd:	6a 3f                	push   $0x3f
  8008df:	ff 55 08             	call   *0x8(%ebp)
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 0d                	jmp    8008f4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	ff 75 0c             	pushl  0xc(%ebp)
  8008ed:	52                   	push   %edx
  8008ee:	ff 55 08             	call   *0x8(%ebp)
  8008f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f4:	83 eb 01             	sub    $0x1,%ebx
  8008f7:	eb 1a                	jmp    800913 <vprintfmt+0x23f>
  8008f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800902:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800905:	eb 0c                	jmp    800913 <vprintfmt+0x23f>
  800907:	89 75 08             	mov    %esi,0x8(%ebp)
  80090a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80090d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800910:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800913:	83 c7 01             	add    $0x1,%edi
  800916:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80091a:	0f be d0             	movsbl %al,%edx
  80091d:	85 d2                	test   %edx,%edx
  80091f:	74 23                	je     800944 <vprintfmt+0x270>
  800921:	85 f6                	test   %esi,%esi
  800923:	78 a1                	js     8008c6 <vprintfmt+0x1f2>
  800925:	83 ee 01             	sub    $0x1,%esi
  800928:	79 9c                	jns    8008c6 <vprintfmt+0x1f2>
  80092a:	89 df                	mov    %ebx,%edi
  80092c:	8b 75 08             	mov    0x8(%ebp),%esi
  80092f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800932:	eb 18                	jmp    80094c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	53                   	push   %ebx
  800938:	6a 20                	push   $0x20
  80093a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80093c:	83 ef 01             	sub    $0x1,%edi
  80093f:	83 c4 10             	add    $0x10,%esp
  800942:	eb 08                	jmp    80094c <vprintfmt+0x278>
  800944:	89 df                	mov    %ebx,%edi
  800946:	8b 75 08             	mov    0x8(%ebp),%esi
  800949:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094c:	85 ff                	test   %edi,%edi
  80094e:	7f e4                	jg     800934 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800950:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800953:	e9 a2 fd ff ff       	jmp    8006fa <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800958:	83 fa 01             	cmp    $0x1,%edx
  80095b:	7e 16                	jle    800973 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80095d:	8b 45 14             	mov    0x14(%ebp),%eax
  800960:	8d 50 08             	lea    0x8(%eax),%edx
  800963:	89 55 14             	mov    %edx,0x14(%ebp)
  800966:	8b 50 04             	mov    0x4(%eax),%edx
  800969:	8b 00                	mov    (%eax),%eax
  80096b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80096e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800971:	eb 32                	jmp    8009a5 <vprintfmt+0x2d1>
	else if (lflag)
  800973:	85 d2                	test   %edx,%edx
  800975:	74 18                	je     80098f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8d 50 04             	lea    0x4(%eax),%edx
  80097d:	89 55 14             	mov    %edx,0x14(%ebp)
  800980:	8b 00                	mov    (%eax),%eax
  800982:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800985:	89 c1                	mov    %eax,%ecx
  800987:	c1 f9 1f             	sar    $0x1f,%ecx
  80098a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80098d:	eb 16                	jmp    8009a5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099d:	89 c1                	mov    %eax,%ecx
  80099f:	c1 f9 1f             	sar    $0x1f,%ecx
  8009a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b4:	79 74                	jns    800a2a <vprintfmt+0x356>
				putch('-', putdat);
  8009b6:	83 ec 08             	sub    $0x8,%esp
  8009b9:	53                   	push   %ebx
  8009ba:	6a 2d                	push   $0x2d
  8009bc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009c4:	f7 d8                	neg    %eax
  8009c6:	83 d2 00             	adc    $0x0,%edx
  8009c9:	f7 da                	neg    %edx
  8009cb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009d3:	eb 55                	jmp    800a2a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d8:	e8 83 fc ff ff       	call   800660 <getuint>
			base = 10;
  8009dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009e2:	eb 46                	jmp    800a2a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8009e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e7:	e8 74 fc ff ff       	call   800660 <getuint>
			base = 8;
  8009ec:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8009f1:	eb 37                	jmp    800a2a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	53                   	push   %ebx
  8009f7:	6a 30                	push   $0x30
  8009f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8009fb:	83 c4 08             	add    $0x8,%esp
  8009fe:	53                   	push   %ebx
  8009ff:	6a 78                	push   $0x78
  800a01:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a03:	8b 45 14             	mov    0x14(%ebp),%eax
  800a06:	8d 50 04             	lea    0x4(%eax),%edx
  800a09:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a0c:	8b 00                	mov    (%eax),%eax
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a13:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a16:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a1b:	eb 0d                	jmp    800a2a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a1d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a20:	e8 3b fc ff ff       	call   800660 <getuint>
			base = 16;
  800a25:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a2a:	83 ec 0c             	sub    $0xc,%esp
  800a2d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a31:	57                   	push   %edi
  800a32:	ff 75 e0             	pushl  -0x20(%ebp)
  800a35:	51                   	push   %ecx
  800a36:	52                   	push   %edx
  800a37:	50                   	push   %eax
  800a38:	89 da                	mov    %ebx,%edx
  800a3a:	89 f0                	mov    %esi,%eax
  800a3c:	e8 70 fb ff ff       	call   8005b1 <printnum>
			break;
  800a41:	83 c4 20             	add    $0x20,%esp
  800a44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a47:	e9 ae fc ff ff       	jmp    8006fa <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	53                   	push   %ebx
  800a50:	51                   	push   %ecx
  800a51:	ff d6                	call   *%esi
			break;
  800a53:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a59:	e9 9c fc ff ff       	jmp    8006fa <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a5e:	83 ec 08             	sub    $0x8,%esp
  800a61:	53                   	push   %ebx
  800a62:	6a 25                	push   $0x25
  800a64:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a66:	83 c4 10             	add    $0x10,%esp
  800a69:	eb 03                	jmp    800a6e <vprintfmt+0x39a>
  800a6b:	83 ef 01             	sub    $0x1,%edi
  800a6e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a72:	75 f7                	jne    800a6b <vprintfmt+0x397>
  800a74:	e9 81 fc ff ff       	jmp    8006fa <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 18             	sub    $0x18,%esp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a90:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a94:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	74 26                	je     800ac8 <vsnprintf+0x47>
  800aa2:	85 d2                	test   %edx,%edx
  800aa4:	7e 22                	jle    800ac8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aa6:	ff 75 14             	pushl  0x14(%ebp)
  800aa9:	ff 75 10             	pushl  0x10(%ebp)
  800aac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aaf:	50                   	push   %eax
  800ab0:	68 9a 06 80 00       	push   $0x80069a
  800ab5:	e8 1a fc ff ff       	call   8006d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800abd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	eb 05                	jmp    800acd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ac8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ad5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ad8:	50                   	push   %eax
  800ad9:	ff 75 10             	pushl  0x10(%ebp)
  800adc:	ff 75 0c             	pushl  0xc(%ebp)
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	e8 9a ff ff ff       	call   800a81 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	eb 03                	jmp    800af9 <strlen+0x10>
		n++;
  800af6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800af9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800afd:	75 f7                	jne    800af6 <strlen+0xd>
		n++;
	return n;
}
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	eb 03                	jmp    800b14 <strnlen+0x13>
		n++;
  800b11:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b14:	39 c2                	cmp    %eax,%edx
  800b16:	74 08                	je     800b20 <strnlen+0x1f>
  800b18:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b1c:	75 f3                	jne    800b11 <strnlen+0x10>
  800b1e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	83 c2 01             	add    $0x1,%edx
  800b31:	83 c1 01             	add    $0x1,%ecx
  800b34:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b38:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b3b:	84 db                	test   %bl,%bl
  800b3d:	75 ef                	jne    800b2e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b49:	53                   	push   %ebx
  800b4a:	e8 9a ff ff ff       	call   800ae9 <strlen>
  800b4f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b52:	ff 75 0c             	pushl  0xc(%ebp)
  800b55:	01 d8                	add    %ebx,%eax
  800b57:	50                   	push   %eax
  800b58:	e8 c5 ff ff ff       	call   800b22 <strcpy>
	return dst;
}
  800b5d:	89 d8                	mov    %ebx,%eax
  800b5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b74:	89 f2                	mov    %esi,%edx
  800b76:	eb 0f                	jmp    800b87 <strncpy+0x23>
		*dst++ = *src;
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	0f b6 01             	movzbl (%ecx),%eax
  800b7e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b81:	80 39 01             	cmpb   $0x1,(%ecx)
  800b84:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b87:	39 da                	cmp    %ebx,%edx
  800b89:	75 ed                	jne    800b78 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	8b 75 08             	mov    0x8(%ebp),%esi
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 10             	mov    0x10(%ebp),%edx
  800b9f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ba1:	85 d2                	test   %edx,%edx
  800ba3:	74 21                	je     800bc6 <strlcpy+0x35>
  800ba5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ba9:	89 f2                	mov    %esi,%edx
  800bab:	eb 09                	jmp    800bb6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bad:	83 c2 01             	add    $0x1,%edx
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb6:	39 c2                	cmp    %eax,%edx
  800bb8:	74 09                	je     800bc3 <strlcpy+0x32>
  800bba:	0f b6 19             	movzbl (%ecx),%ebx
  800bbd:	84 db                	test   %bl,%bl
  800bbf:	75 ec                	jne    800bad <strlcpy+0x1c>
  800bc1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bc3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc6:	29 f0                	sub    %esi,%eax
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bd5:	eb 06                	jmp    800bdd <strcmp+0x11>
		p++, q++;
  800bd7:	83 c1 01             	add    $0x1,%ecx
  800bda:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bdd:	0f b6 01             	movzbl (%ecx),%eax
  800be0:	84 c0                	test   %al,%al
  800be2:	74 04                	je     800be8 <strcmp+0x1c>
  800be4:	3a 02                	cmp    (%edx),%al
  800be6:	74 ef                	je     800bd7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800be8:	0f b6 c0             	movzbl %al,%eax
  800beb:	0f b6 12             	movzbl (%edx),%edx
  800bee:	29 d0                	sub    %edx,%eax
}
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	53                   	push   %ebx
  800bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfc:	89 c3                	mov    %eax,%ebx
  800bfe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c01:	eb 06                	jmp    800c09 <strncmp+0x17>
		n--, p++, q++;
  800c03:	83 c0 01             	add    $0x1,%eax
  800c06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c09:	39 d8                	cmp    %ebx,%eax
  800c0b:	74 15                	je     800c22 <strncmp+0x30>
  800c0d:	0f b6 08             	movzbl (%eax),%ecx
  800c10:	84 c9                	test   %cl,%cl
  800c12:	74 04                	je     800c18 <strncmp+0x26>
  800c14:	3a 0a                	cmp    (%edx),%cl
  800c16:	74 eb                	je     800c03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c18:	0f b6 00             	movzbl (%eax),%eax
  800c1b:	0f b6 12             	movzbl (%edx),%edx
  800c1e:	29 d0                	sub    %edx,%eax
  800c20:	eb 05                	jmp    800c27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c34:	eb 07                	jmp    800c3d <strchr+0x13>
		if (*s == c)
  800c36:	38 ca                	cmp    %cl,%dl
  800c38:	74 0f                	je     800c49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c3a:	83 c0 01             	add    $0x1,%eax
  800c3d:	0f b6 10             	movzbl (%eax),%edx
  800c40:	84 d2                	test   %dl,%dl
  800c42:	75 f2                	jne    800c36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c55:	eb 03                	jmp    800c5a <strfind+0xf>
  800c57:	83 c0 01             	add    $0x1,%eax
  800c5a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c5d:	38 ca                	cmp    %cl,%dl
  800c5f:	74 04                	je     800c65 <strfind+0x1a>
  800c61:	84 d2                	test   %dl,%dl
  800c63:	75 f2                	jne    800c57 <strfind+0xc>
			break;
	return (char *) s;
}
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c73:	85 c9                	test   %ecx,%ecx
  800c75:	74 36                	je     800cad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7d:	75 28                	jne    800ca7 <memset+0x40>
  800c7f:	f6 c1 03             	test   $0x3,%cl
  800c82:	75 23                	jne    800ca7 <memset+0x40>
		c &= 0xFF;
  800c84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c88:	89 d3                	mov    %edx,%ebx
  800c8a:	c1 e3 08             	shl    $0x8,%ebx
  800c8d:	89 d6                	mov    %edx,%esi
  800c8f:	c1 e6 18             	shl    $0x18,%esi
  800c92:	89 d0                	mov    %edx,%eax
  800c94:	c1 e0 10             	shl    $0x10,%eax
  800c97:	09 f0                	or     %esi,%eax
  800c99:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c9b:	89 d8                	mov    %ebx,%eax
  800c9d:	09 d0                	or     %edx,%eax
  800c9f:	c1 e9 02             	shr    $0x2,%ecx
  800ca2:	fc                   	cld    
  800ca3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ca5:	eb 06                	jmp    800cad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caa:	fc                   	cld    
  800cab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cad:	89 f8                	mov    %edi,%eax
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cc2:	39 c6                	cmp    %eax,%esi
  800cc4:	73 35                	jae    800cfb <memmove+0x47>
  800cc6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc9:	39 d0                	cmp    %edx,%eax
  800ccb:	73 2e                	jae    800cfb <memmove+0x47>
		s += n;
		d += n;
  800ccd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	09 fe                	or     %edi,%esi
  800cd4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cda:	75 13                	jne    800cef <memmove+0x3b>
  800cdc:	f6 c1 03             	test   $0x3,%cl
  800cdf:	75 0e                	jne    800cef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ce1:	83 ef 04             	sub    $0x4,%edi
  800ce4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ce7:	c1 e9 02             	shr    $0x2,%ecx
  800cea:	fd                   	std    
  800ceb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ced:	eb 09                	jmp    800cf8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cef:	83 ef 01             	sub    $0x1,%edi
  800cf2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cf5:	fd                   	std    
  800cf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cf8:	fc                   	cld    
  800cf9:	eb 1d                	jmp    800d18 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	09 c2                	or     %eax,%edx
  800cff:	f6 c2 03             	test   $0x3,%dl
  800d02:	75 0f                	jne    800d13 <memmove+0x5f>
  800d04:	f6 c1 03             	test   $0x3,%cl
  800d07:	75 0a                	jne    800d13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d09:	c1 e9 02             	shr    $0x2,%ecx
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	fc                   	cld    
  800d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d11:	eb 05                	jmp    800d18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d13:	89 c7                	mov    %eax,%edi
  800d15:	fc                   	cld    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d1f:	ff 75 10             	pushl  0x10(%ebp)
  800d22:	ff 75 0c             	pushl  0xc(%ebp)
  800d25:	ff 75 08             	pushl  0x8(%ebp)
  800d28:	e8 87 ff ff ff       	call   800cb4 <memmove>
}
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    

00800d2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3a:	89 c6                	mov    %eax,%esi
  800d3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3f:	eb 1a                	jmp    800d5b <memcmp+0x2c>
		if (*s1 != *s2)
  800d41:	0f b6 08             	movzbl (%eax),%ecx
  800d44:	0f b6 1a             	movzbl (%edx),%ebx
  800d47:	38 d9                	cmp    %bl,%cl
  800d49:	74 0a                	je     800d55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d4b:	0f b6 c1             	movzbl %cl,%eax
  800d4e:	0f b6 db             	movzbl %bl,%ebx
  800d51:	29 d8                	sub    %ebx,%eax
  800d53:	eb 0f                	jmp    800d64 <memcmp+0x35>
		s1++, s2++;
  800d55:	83 c0 01             	add    $0x1,%eax
  800d58:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5b:	39 f0                	cmp    %esi,%eax
  800d5d:	75 e2                	jne    800d41 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	53                   	push   %ebx
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d74:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d78:	eb 0a                	jmp    800d84 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d7a:	0f b6 10             	movzbl (%eax),%edx
  800d7d:	39 da                	cmp    %ebx,%edx
  800d7f:	74 07                	je     800d88 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d81:	83 c0 01             	add    $0x1,%eax
  800d84:	39 c8                	cmp    %ecx,%eax
  800d86:	72 f2                	jb     800d7a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d88:	5b                   	pop    %ebx
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d97:	eb 03                	jmp    800d9c <strtol+0x11>
		s++;
  800d99:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d9c:	0f b6 01             	movzbl (%ecx),%eax
  800d9f:	3c 20                	cmp    $0x20,%al
  800da1:	74 f6                	je     800d99 <strtol+0xe>
  800da3:	3c 09                	cmp    $0x9,%al
  800da5:	74 f2                	je     800d99 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800da7:	3c 2b                	cmp    $0x2b,%al
  800da9:	75 0a                	jne    800db5 <strtol+0x2a>
		s++;
  800dab:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dae:	bf 00 00 00 00       	mov    $0x0,%edi
  800db3:	eb 11                	jmp    800dc6 <strtol+0x3b>
  800db5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dba:	3c 2d                	cmp    $0x2d,%al
  800dbc:	75 08                	jne    800dc6 <strtol+0x3b>
		s++, neg = 1;
  800dbe:	83 c1 01             	add    $0x1,%ecx
  800dc1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dcc:	75 15                	jne    800de3 <strtol+0x58>
  800dce:	80 39 30             	cmpb   $0x30,(%ecx)
  800dd1:	75 10                	jne    800de3 <strtol+0x58>
  800dd3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800dd7:	75 7c                	jne    800e55 <strtol+0xca>
		s += 2, base = 16;
  800dd9:	83 c1 02             	add    $0x2,%ecx
  800ddc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800de1:	eb 16                	jmp    800df9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800de3:	85 db                	test   %ebx,%ebx
  800de5:	75 12                	jne    800df9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800de7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dec:	80 39 30             	cmpb   $0x30,(%ecx)
  800def:	75 08                	jne    800df9 <strtol+0x6e>
		s++, base = 8;
  800df1:	83 c1 01             	add    $0x1,%ecx
  800df4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e01:	0f b6 11             	movzbl (%ecx),%edx
  800e04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e07:	89 f3                	mov    %esi,%ebx
  800e09:	80 fb 09             	cmp    $0x9,%bl
  800e0c:	77 08                	ja     800e16 <strtol+0x8b>
			dig = *s - '0';
  800e0e:	0f be d2             	movsbl %dl,%edx
  800e11:	83 ea 30             	sub    $0x30,%edx
  800e14:	eb 22                	jmp    800e38 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e19:	89 f3                	mov    %esi,%ebx
  800e1b:	80 fb 19             	cmp    $0x19,%bl
  800e1e:	77 08                	ja     800e28 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e20:	0f be d2             	movsbl %dl,%edx
  800e23:	83 ea 57             	sub    $0x57,%edx
  800e26:	eb 10                	jmp    800e38 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e28:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e2b:	89 f3                	mov    %esi,%ebx
  800e2d:	80 fb 19             	cmp    $0x19,%bl
  800e30:	77 16                	ja     800e48 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e32:	0f be d2             	movsbl %dl,%edx
  800e35:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e38:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e3b:	7d 0b                	jge    800e48 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e3d:	83 c1 01             	add    $0x1,%ecx
  800e40:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e44:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e46:	eb b9                	jmp    800e01 <strtol+0x76>

	if (endptr)
  800e48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e4c:	74 0d                	je     800e5b <strtol+0xd0>
		*endptr = (char *) s;
  800e4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e51:	89 0e                	mov    %ecx,(%esi)
  800e53:	eb 06                	jmp    800e5b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e55:	85 db                	test   %ebx,%ebx
  800e57:	74 98                	je     800df1 <strtol+0x66>
  800e59:	eb 9e                	jmp    800df9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e5b:	89 c2                	mov    %eax,%edx
  800e5d:	f7 da                	neg    %edx
  800e5f:	85 ff                	test   %edi,%edi
  800e61:	0f 45 c2             	cmovne %edx,%eax
}
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 c7                	mov    %eax,%edi
  800e7e:	89 c6                	mov    %eax,%esi
  800e80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e82:	5b                   	pop    %ebx
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	57                   	push   %edi
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e92:	b8 01 00 00 00       	mov    $0x1,%eax
  800e97:	89 d1                	mov    %edx,%ecx
  800e99:	89 d3                	mov    %edx,%ebx
  800e9b:	89 d7                	mov    %edx,%edi
  800e9d:	89 d6                	mov    %edx,%esi
  800e9f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb4:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 cb                	mov    %ecx,%ebx
  800ebe:	89 cf                	mov    %ecx,%edi
  800ec0:	89 ce                	mov    %ecx,%esi
  800ec2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7e 17                	jle    800edf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	50                   	push   %eax
  800ecc:	6a 03                	push   $0x3
  800ece:	68 9f 2a 80 00       	push   $0x802a9f
  800ed3:	6a 23                	push   $0x23
  800ed5:	68 bc 2a 80 00       	push   $0x802abc
  800eda:	e8 9a 13 00 00       	call   802279 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ef7:	89 d1                	mov    %edx,%ecx
  800ef9:	89 d3                	mov    %edx,%ebx
  800efb:	89 d7                	mov    %edx,%edi
  800efd:	89 d6                	mov    %edx,%esi
  800eff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_yield>:

void
sys_yield(void)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f16:	89 d1                	mov    %edx,%ecx
  800f18:	89 d3                	mov    %edx,%ebx
  800f1a:	89 d7                	mov    %edx,%edi
  800f1c:	89 d6                	mov    %edx,%esi
  800f1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	be 00 00 00 00       	mov    $0x0,%esi
  800f33:	b8 04 00 00 00       	mov    $0x4,%eax
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f41:	89 f7                	mov    %esi,%edi
  800f43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	7e 17                	jle    800f60 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	50                   	push   %eax
  800f4d:	6a 04                	push   $0x4
  800f4f:	68 9f 2a 80 00       	push   $0x802a9f
  800f54:	6a 23                	push   $0x23
  800f56:	68 bc 2a 80 00       	push   $0x802abc
  800f5b:	e8 19 13 00 00       	call   802279 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	57                   	push   %edi
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f71:	b8 05 00 00 00       	mov    $0x5,%eax
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f82:	8b 75 18             	mov    0x18(%ebp),%esi
  800f85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	7e 17                	jle    800fa2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	50                   	push   %eax
  800f8f:	6a 05                	push   $0x5
  800f91:	68 9f 2a 80 00       	push   $0x802a9f
  800f96:	6a 23                	push   $0x23
  800f98:	68 bc 2a 80 00       	push   $0x802abc
  800f9d:	e8 d7 12 00 00       	call   802279 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	89 df                	mov    %ebx,%edi
  800fc5:	89 de                	mov    %ebx,%esi
  800fc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	7e 17                	jle    800fe4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	50                   	push   %eax
  800fd1:	6a 06                	push   $0x6
  800fd3:	68 9f 2a 80 00       	push   $0x802a9f
  800fd8:	6a 23                	push   $0x23
  800fda:	68 bc 2a 80 00       	push   $0x802abc
  800fdf:	e8 95 12 00 00       	call   802279 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fe4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	57                   	push   %edi
  800ff0:	56                   	push   %esi
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffa:	b8 08 00 00 00       	mov    $0x8,%eax
  800fff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801002:	8b 55 08             	mov    0x8(%ebp),%edx
  801005:	89 df                	mov    %ebx,%edi
  801007:	89 de                	mov    %ebx,%esi
  801009:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	7e 17                	jle    801026 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	50                   	push   %eax
  801013:	6a 08                	push   $0x8
  801015:	68 9f 2a 80 00       	push   $0x802a9f
  80101a:	6a 23                	push   $0x23
  80101c:	68 bc 2a 80 00       	push   $0x802abc
  801021:	e8 53 12 00 00       	call   802279 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801026:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5f                   	pop    %edi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103c:	b8 09 00 00 00       	mov    $0x9,%eax
  801041:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	89 df                	mov    %ebx,%edi
  801049:	89 de                	mov    %ebx,%esi
  80104b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	7e 17                	jle    801068 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	50                   	push   %eax
  801055:	6a 09                	push   $0x9
  801057:	68 9f 2a 80 00       	push   $0x802a9f
  80105c:	6a 23                	push   $0x23
  80105e:	68 bc 2a 80 00       	push   $0x802abc
  801063:	e8 11 12 00 00       	call   802279 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801068:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801079:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 df                	mov    %ebx,%edi
  80108b:	89 de                	mov    %ebx,%esi
  80108d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108f:	85 c0                	test   %eax,%eax
  801091:	7e 17                	jle    8010aa <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	6a 0a                	push   $0xa
  801099:	68 9f 2a 80 00       	push   $0x802a9f
  80109e:	6a 23                	push   $0x23
  8010a0:	68 bc 2a 80 00       	push   $0x802abc
  8010a5:	e8 cf 11 00 00       	call   802279 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b8:	be 00 00 00 00       	mov    $0x0,%esi
  8010bd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ce:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
  8010db:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010eb:	89 cb                	mov    %ecx,%ebx
  8010ed:	89 cf                	mov    %ecx,%edi
  8010ef:	89 ce                	mov    %ecx,%esi
  8010f1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	7e 17                	jle    80110e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	50                   	push   %eax
  8010fb:	6a 0d                	push   $0xd
  8010fd:	68 9f 2a 80 00       	push   $0x802a9f
  801102:	6a 23                	push   $0x23
  801104:	68 bc 2a 80 00       	push   $0x802abc
  801109:	e8 6b 11 00 00       	call   802279 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80110e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111c:	ba 00 00 00 00       	mov    $0x0,%edx
  801121:	b8 0e 00 00 00       	mov    $0xe,%eax
  801126:	89 d1                	mov    %edx,%ecx
  801128:	89 d3                	mov    %edx,%ebx
  80112a:	89 d7                	mov    %edx,%edi
  80112c:	89 d6                	mov    %edx,%esi
  80112e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	05 00 00 00 30       	add    $0x30000000,%eax
  801140:	c1 e8 0c             	shr    $0xc,%eax
}
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801148:	8b 45 08             	mov    0x8(%ebp),%eax
  80114b:	05 00 00 00 30       	add    $0x30000000,%eax
  801150:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801155:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801162:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801167:	89 c2                	mov    %eax,%edx
  801169:	c1 ea 16             	shr    $0x16,%edx
  80116c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801173:	f6 c2 01             	test   $0x1,%dl
  801176:	74 11                	je     801189 <fd_alloc+0x2d>
  801178:	89 c2                	mov    %eax,%edx
  80117a:	c1 ea 0c             	shr    $0xc,%edx
  80117d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801184:	f6 c2 01             	test   $0x1,%dl
  801187:	75 09                	jne    801192 <fd_alloc+0x36>
			*fd_store = fd;
  801189:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
  801190:	eb 17                	jmp    8011a9 <fd_alloc+0x4d>
  801192:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801197:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119c:	75 c9                	jne    801167 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80119e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b1:	83 f8 1f             	cmp    $0x1f,%eax
  8011b4:	77 36                	ja     8011ec <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b6:	c1 e0 0c             	shl    $0xc,%eax
  8011b9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	c1 ea 16             	shr    $0x16,%edx
  8011c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ca:	f6 c2 01             	test   $0x1,%dl
  8011cd:	74 24                	je     8011f3 <fd_lookup+0x48>
  8011cf:	89 c2                	mov    %eax,%edx
  8011d1:	c1 ea 0c             	shr    $0xc,%edx
  8011d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011db:	f6 c2 01             	test   $0x1,%dl
  8011de:	74 1a                	je     8011fa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e3:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ea:	eb 13                	jmp    8011ff <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f1:	eb 0c                	jmp    8011ff <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f8:	eb 05                	jmp    8011ff <fd_lookup+0x54>
  8011fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120a:	ba 48 2b 80 00       	mov    $0x802b48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80120f:	eb 13                	jmp    801224 <dev_lookup+0x23>
  801211:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801214:	39 08                	cmp    %ecx,(%eax)
  801216:	75 0c                	jne    801224 <dev_lookup+0x23>
			*dev = devtab[i];
  801218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121d:	b8 00 00 00 00       	mov    $0x0,%eax
  801222:	eb 2e                	jmp    801252 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801224:	8b 02                	mov    (%edx),%eax
  801226:	85 c0                	test   %eax,%eax
  801228:	75 e7                	jne    801211 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122a:	a1 18 40 80 00       	mov    0x804018,%eax
  80122f:	8b 40 48             	mov    0x48(%eax),%eax
  801232:	83 ec 04             	sub    $0x4,%esp
  801235:	51                   	push   %ecx
  801236:	50                   	push   %eax
  801237:	68 cc 2a 80 00       	push   $0x802acc
  80123c:	e8 5c f3 ff ff       	call   80059d <cprintf>
	*dev = 0;
  801241:	8b 45 0c             	mov    0xc(%ebp),%eax
  801244:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	83 ec 10             	sub    $0x10,%esp
  80125c:	8b 75 08             	mov    0x8(%ebp),%esi
  80125f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80126c:	c1 e8 0c             	shr    $0xc,%eax
  80126f:	50                   	push   %eax
  801270:	e8 36 ff ff ff       	call   8011ab <fd_lookup>
  801275:	83 c4 08             	add    $0x8,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 05                	js     801281 <fd_close+0x2d>
	    || fd != fd2)
  80127c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80127f:	74 0c                	je     80128d <fd_close+0x39>
		return (must_exist ? r : 0);
  801281:	84 db                	test   %bl,%bl
  801283:	ba 00 00 00 00       	mov    $0x0,%edx
  801288:	0f 44 c2             	cmove  %edx,%eax
  80128b:	eb 41                	jmp    8012ce <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	ff 36                	pushl  (%esi)
  801296:	e8 66 ff ff ff       	call   801201 <dev_lookup>
  80129b:	89 c3                	mov    %eax,%ebx
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 1a                	js     8012be <fd_close+0x6a>
		if (dev->dev_close)
  8012a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012aa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	74 0b                	je     8012be <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b3:	83 ec 0c             	sub    $0xc,%esp
  8012b6:	56                   	push   %esi
  8012b7:	ff d0                	call   *%eax
  8012b9:	89 c3                	mov    %eax,%ebx
  8012bb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	56                   	push   %esi
  8012c2:	6a 00                	push   $0x0
  8012c4:	e8 e1 fc ff ff       	call   800faa <sys_page_unmap>
	return r;
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	89 d8                	mov    %ebx,%eax
}
  8012ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 c4 fe ff ff       	call   8011ab <fd_lookup>
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 10                	js     8012fe <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	6a 01                	push   $0x1
  8012f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f6:	e8 59 ff ff ff       	call   801254 <fd_close>
  8012fb:	83 c4 10             	add    $0x10,%esp
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <close_all>:

void
close_all(void)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	53                   	push   %ebx
  801304:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801307:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	53                   	push   %ebx
  801310:	e8 c0 ff ff ff       	call   8012d5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801315:	83 c3 01             	add    $0x1,%ebx
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	83 fb 20             	cmp    $0x20,%ebx
  80131e:	75 ec                	jne    80130c <close_all+0xc>
		close(i);
}
  801320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801323:	c9                   	leave  
  801324:	c3                   	ret    

00801325 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	57                   	push   %edi
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	83 ec 2c             	sub    $0x2c,%esp
  80132e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801331:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	ff 75 08             	pushl  0x8(%ebp)
  801338:	e8 6e fe ff ff       	call   8011ab <fd_lookup>
  80133d:	83 c4 08             	add    $0x8,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	0f 88 c1 00 00 00    	js     801409 <dup+0xe4>
		return r;
	close(newfdnum);
  801348:	83 ec 0c             	sub    $0xc,%esp
  80134b:	56                   	push   %esi
  80134c:	e8 84 ff ff ff       	call   8012d5 <close>

	newfd = INDEX2FD(newfdnum);
  801351:	89 f3                	mov    %esi,%ebx
  801353:	c1 e3 0c             	shl    $0xc,%ebx
  801356:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80135c:	83 c4 04             	add    $0x4,%esp
  80135f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801362:	e8 de fd ff ff       	call   801145 <fd2data>
  801367:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801369:	89 1c 24             	mov    %ebx,(%esp)
  80136c:	e8 d4 fd ff ff       	call   801145 <fd2data>
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801377:	89 f8                	mov    %edi,%eax
  801379:	c1 e8 16             	shr    $0x16,%eax
  80137c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801383:	a8 01                	test   $0x1,%al
  801385:	74 37                	je     8013be <dup+0x99>
  801387:	89 f8                	mov    %edi,%eax
  801389:	c1 e8 0c             	shr    $0xc,%eax
  80138c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801393:	f6 c2 01             	test   $0x1,%dl
  801396:	74 26                	je     8013be <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801398:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a7:	50                   	push   %eax
  8013a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ab:	6a 00                	push   $0x0
  8013ad:	57                   	push   %edi
  8013ae:	6a 00                	push   $0x0
  8013b0:	e8 b3 fb ff ff       	call   800f68 <sys_page_map>
  8013b5:	89 c7                	mov    %eax,%edi
  8013b7:	83 c4 20             	add    $0x20,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 2e                	js     8013ec <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c1:	89 d0                	mov    %edx,%eax
  8013c3:	c1 e8 0c             	shr    $0xc,%eax
  8013c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cd:	83 ec 0c             	sub    $0xc,%esp
  8013d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d5:	50                   	push   %eax
  8013d6:	53                   	push   %ebx
  8013d7:	6a 00                	push   $0x0
  8013d9:	52                   	push   %edx
  8013da:	6a 00                	push   $0x0
  8013dc:	e8 87 fb ff ff       	call   800f68 <sys_page_map>
  8013e1:	89 c7                	mov    %eax,%edi
  8013e3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e8:	85 ff                	test   %edi,%edi
  8013ea:	79 1d                	jns    801409 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	53                   	push   %ebx
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 b3 fb ff ff       	call   800faa <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f7:	83 c4 08             	add    $0x8,%esp
  8013fa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 a6 fb ff ff       	call   800faa <sys_page_unmap>
	return r;
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	89 f8                	mov    %edi,%eax
}
  801409:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140c:	5b                   	pop    %ebx
  80140d:	5e                   	pop    %esi
  80140e:	5f                   	pop    %edi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	53                   	push   %ebx
  801415:	83 ec 14             	sub    $0x14,%esp
  801418:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	53                   	push   %ebx
  801420:	e8 86 fd ff ff       	call   8011ab <fd_lookup>
  801425:	83 c4 08             	add    $0x8,%esp
  801428:	89 c2                	mov    %eax,%edx
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 6d                	js     80149b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801438:	ff 30                	pushl  (%eax)
  80143a:	e8 c2 fd ff ff       	call   801201 <dev_lookup>
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 4c                	js     801492 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801446:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801449:	8b 42 08             	mov    0x8(%edx),%eax
  80144c:	83 e0 03             	and    $0x3,%eax
  80144f:	83 f8 01             	cmp    $0x1,%eax
  801452:	75 21                	jne    801475 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801454:	a1 18 40 80 00       	mov    0x804018,%eax
  801459:	8b 40 48             	mov    0x48(%eax),%eax
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	53                   	push   %ebx
  801460:	50                   	push   %eax
  801461:	68 0d 2b 80 00       	push   $0x802b0d
  801466:	e8 32 f1 ff ff       	call   80059d <cprintf>
		return -E_INVAL;
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801473:	eb 26                	jmp    80149b <read+0x8a>
	}
	if (!dev->dev_read)
  801475:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801478:	8b 40 08             	mov    0x8(%eax),%eax
  80147b:	85 c0                	test   %eax,%eax
  80147d:	74 17                	je     801496 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	ff 75 10             	pushl  0x10(%ebp)
  801485:	ff 75 0c             	pushl  0xc(%ebp)
  801488:	52                   	push   %edx
  801489:	ff d0                	call   *%eax
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	eb 09                	jmp    80149b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801492:	89 c2                	mov    %eax,%edx
  801494:	eb 05                	jmp    80149b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801496:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80149b:	89 d0                	mov    %edx,%eax
  80149d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	57                   	push   %edi
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b6:	eb 21                	jmp    8014d9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	89 f0                	mov    %esi,%eax
  8014bd:	29 d8                	sub    %ebx,%eax
  8014bf:	50                   	push   %eax
  8014c0:	89 d8                	mov    %ebx,%eax
  8014c2:	03 45 0c             	add    0xc(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	57                   	push   %edi
  8014c7:	e8 45 ff ff ff       	call   801411 <read>
		if (m < 0)
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 10                	js     8014e3 <readn+0x41>
			return m;
		if (m == 0)
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	74 0a                	je     8014e1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d7:	01 c3                	add    %eax,%ebx
  8014d9:	39 f3                	cmp    %esi,%ebx
  8014db:	72 db                	jb     8014b8 <readn+0x16>
  8014dd:	89 d8                	mov    %ebx,%eax
  8014df:	eb 02                	jmp    8014e3 <readn+0x41>
  8014e1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e6:	5b                   	pop    %ebx
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    

008014eb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 14             	sub    $0x14,%esp
  8014f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f8:	50                   	push   %eax
  8014f9:	53                   	push   %ebx
  8014fa:	e8 ac fc ff ff       	call   8011ab <fd_lookup>
  8014ff:	83 c4 08             	add    $0x8,%esp
  801502:	89 c2                	mov    %eax,%edx
  801504:	85 c0                	test   %eax,%eax
  801506:	78 68                	js     801570 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150e:	50                   	push   %eax
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	ff 30                	pushl  (%eax)
  801514:	e8 e8 fc ff ff       	call   801201 <dev_lookup>
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 47                	js     801567 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801523:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801527:	75 21                	jne    80154a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801529:	a1 18 40 80 00       	mov    0x804018,%eax
  80152e:	8b 40 48             	mov    0x48(%eax),%eax
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	53                   	push   %ebx
  801535:	50                   	push   %eax
  801536:	68 29 2b 80 00       	push   $0x802b29
  80153b:	e8 5d f0 ff ff       	call   80059d <cprintf>
		return -E_INVAL;
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801548:	eb 26                	jmp    801570 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154d:	8b 52 0c             	mov    0xc(%edx),%edx
  801550:	85 d2                	test   %edx,%edx
  801552:	74 17                	je     80156b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	ff 75 10             	pushl  0x10(%ebp)
  80155a:	ff 75 0c             	pushl  0xc(%ebp)
  80155d:	50                   	push   %eax
  80155e:	ff d2                	call   *%edx
  801560:	89 c2                	mov    %eax,%edx
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	eb 09                	jmp    801570 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	89 c2                	mov    %eax,%edx
  801569:	eb 05                	jmp    801570 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801570:	89 d0                	mov    %edx,%eax
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <seek>:

int
seek(int fdnum, off_t offset)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	ff 75 08             	pushl  0x8(%ebp)
  801584:	e8 22 fc ff ff       	call   8011ab <fd_lookup>
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 0e                	js     80159e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801590:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801593:	8b 55 0c             	mov    0xc(%ebp),%edx
  801596:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	53                   	push   %ebx
  8015a4:	83 ec 14             	sub    $0x14,%esp
  8015a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	53                   	push   %ebx
  8015af:	e8 f7 fb ff ff       	call   8011ab <fd_lookup>
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 65                	js     801622 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c7:	ff 30                	pushl  (%eax)
  8015c9:	e8 33 fc ff ff       	call   801201 <dev_lookup>
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 44                	js     801619 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015dc:	75 21                	jne    8015ff <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015de:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e3:	8b 40 48             	mov    0x48(%eax),%eax
  8015e6:	83 ec 04             	sub    $0x4,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	50                   	push   %eax
  8015eb:	68 ec 2a 80 00       	push   $0x802aec
  8015f0:	e8 a8 ef ff ff       	call   80059d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fd:	eb 23                	jmp    801622 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801602:	8b 52 18             	mov    0x18(%edx),%edx
  801605:	85 d2                	test   %edx,%edx
  801607:	74 14                	je     80161d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	ff 75 0c             	pushl  0xc(%ebp)
  80160f:	50                   	push   %eax
  801610:	ff d2                	call   *%edx
  801612:	89 c2                	mov    %eax,%edx
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb 09                	jmp    801622 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801619:	89 c2                	mov    %eax,%edx
  80161b:	eb 05                	jmp    801622 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801622:	89 d0                	mov    %edx,%eax
  801624:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	53                   	push   %ebx
  80162d:	83 ec 14             	sub    $0x14,%esp
  801630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801633:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	ff 75 08             	pushl  0x8(%ebp)
  80163a:	e8 6c fb ff ff       	call   8011ab <fd_lookup>
  80163f:	83 c4 08             	add    $0x8,%esp
  801642:	89 c2                	mov    %eax,%edx
  801644:	85 c0                	test   %eax,%eax
  801646:	78 58                	js     8016a0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	ff 30                	pushl  (%eax)
  801654:	e8 a8 fb ff ff       	call   801201 <dev_lookup>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 37                	js     801697 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801663:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801667:	74 32                	je     80169b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801669:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801673:	00 00 00 
	stat->st_isdir = 0;
  801676:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167d:	00 00 00 
	stat->st_dev = dev;
  801680:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	53                   	push   %ebx
  80168a:	ff 75 f0             	pushl  -0x10(%ebp)
  80168d:	ff 50 14             	call   *0x14(%eax)
  801690:	89 c2                	mov    %eax,%edx
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	eb 09                	jmp    8016a0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801697:	89 c2                	mov    %eax,%edx
  801699:	eb 05                	jmp    8016a0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80169b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a0:	89 d0                	mov    %edx,%eax
  8016a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	6a 00                	push   $0x0
  8016b1:	ff 75 08             	pushl  0x8(%ebp)
  8016b4:	e8 d6 01 00 00       	call   80188f <open>
  8016b9:	89 c3                	mov    %eax,%ebx
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 1b                	js     8016dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	ff 75 0c             	pushl  0xc(%ebp)
  8016c8:	50                   	push   %eax
  8016c9:	e8 5b ff ff ff       	call   801629 <fstat>
  8016ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d0:	89 1c 24             	mov    %ebx,(%esp)
  8016d3:	e8 fd fb ff ff       	call   8012d5 <close>
	return r;
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	89 f0                	mov    %esi,%eax
}
  8016dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	56                   	push   %esi
  8016e8:	53                   	push   %ebx
  8016e9:	89 c6                	mov    %eax,%esi
  8016eb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ed:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  8016f4:	75 12                	jne    801708 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f6:	83 ec 0c             	sub    $0xc,%esp
  8016f9:	6a 01                	push   $0x1
  8016fb:	e8 7a 0c 00 00       	call   80237a <ipc_find_env>
  801700:	a3 10 40 80 00       	mov    %eax,0x804010
  801705:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801708:	6a 07                	push   $0x7
  80170a:	68 00 50 80 00       	push   $0x805000
  80170f:	56                   	push   %esi
  801710:	ff 35 10 40 80 00    	pushl  0x804010
  801716:	e8 0b 0c 00 00       	call   802326 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80171b:	83 c4 0c             	add    $0xc,%esp
  80171e:	6a 00                	push   $0x0
  801720:	53                   	push   %ebx
  801721:	6a 00                	push   $0x0
  801723:	e8 97 0b 00 00       	call   8022bf <ipc_recv>
}
  801728:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801735:	8b 45 08             	mov    0x8(%ebp),%eax
  801738:	8b 40 0c             	mov    0xc(%eax),%eax
  80173b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801740:	8b 45 0c             	mov    0xc(%ebp),%eax
  801743:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801748:	ba 00 00 00 00       	mov    $0x0,%edx
  80174d:	b8 02 00 00 00       	mov    $0x2,%eax
  801752:	e8 8d ff ff ff       	call   8016e4 <fsipc>
}
  801757:	c9                   	leave  
  801758:	c3                   	ret    

00801759 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80175f:	8b 45 08             	mov    0x8(%ebp),%eax
  801762:	8b 40 0c             	mov    0xc(%eax),%eax
  801765:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80176a:	ba 00 00 00 00       	mov    $0x0,%edx
  80176f:	b8 06 00 00 00       	mov    $0x6,%eax
  801774:	e8 6b ff ff ff       	call   8016e4 <fsipc>
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 05 00 00 00       	mov    $0x5,%eax
  80179a:	e8 45 ff ff ff       	call   8016e4 <fsipc>
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 2c                	js     8017cf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	68 00 50 80 00       	push   $0x805000
  8017ab:	53                   	push   %ebx
  8017ac:	e8 71 f3 ff ff       	call   800b22 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b1:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017bc:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017e9:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017ee:	50                   	push   %eax
  8017ef:	ff 75 0c             	pushl  0xc(%ebp)
  8017f2:	68 08 50 80 00       	push   $0x805008
  8017f7:	e8 b8 f4 ff ff       	call   800cb4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801801:	b8 04 00 00 00       	mov    $0x4,%eax
  801806:	e8 d9 fe ff ff       	call   8016e4 <fsipc>

}
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	8b 40 0c             	mov    0xc(%eax),%eax
  80181b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801820:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801826:	ba 00 00 00 00       	mov    $0x0,%edx
  80182b:	b8 03 00 00 00       	mov    $0x3,%eax
  801830:	e8 af fe ff ff       	call   8016e4 <fsipc>
  801835:	89 c3                	mov    %eax,%ebx
  801837:	85 c0                	test   %eax,%eax
  801839:	78 4b                	js     801886 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80183b:	39 c6                	cmp    %eax,%esi
  80183d:	73 16                	jae    801855 <devfile_read+0x48>
  80183f:	68 5c 2b 80 00       	push   $0x802b5c
  801844:	68 63 2b 80 00       	push   $0x802b63
  801849:	6a 7c                	push   $0x7c
  80184b:	68 78 2b 80 00       	push   $0x802b78
  801850:	e8 24 0a 00 00       	call   802279 <_panic>
	assert(r <= PGSIZE);
  801855:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80185a:	7e 16                	jle    801872 <devfile_read+0x65>
  80185c:	68 83 2b 80 00       	push   $0x802b83
  801861:	68 63 2b 80 00       	push   $0x802b63
  801866:	6a 7d                	push   $0x7d
  801868:	68 78 2b 80 00       	push   $0x802b78
  80186d:	e8 07 0a 00 00       	call   802279 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801872:	83 ec 04             	sub    $0x4,%esp
  801875:	50                   	push   %eax
  801876:	68 00 50 80 00       	push   $0x805000
  80187b:	ff 75 0c             	pushl  0xc(%ebp)
  80187e:	e8 31 f4 ff ff       	call   800cb4 <memmove>
	return r;
  801883:	83 c4 10             	add    $0x10,%esp
}
  801886:	89 d8                	mov    %ebx,%eax
  801888:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5e                   	pop    %esi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	53                   	push   %ebx
  801893:	83 ec 20             	sub    $0x20,%esp
  801896:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801899:	53                   	push   %ebx
  80189a:	e8 4a f2 ff ff       	call   800ae9 <strlen>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a7:	7f 67                	jg     801910 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	e8 a7 f8 ff ff       	call   80115c <fd_alloc>
  8018b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 57                	js     801915 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	68 00 50 80 00       	push   $0x805000
  8018c7:	e8 56 f2 ff ff       	call   800b22 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018dc:	e8 03 fe ff ff       	call   8016e4 <fsipc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	79 14                	jns    8018fe <open+0x6f>
		fd_close(fd, 0);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	6a 00                	push   $0x0
  8018ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f2:	e8 5d f9 ff ff       	call   801254 <fd_close>
		return r;
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	89 da                	mov    %ebx,%edx
  8018fc:	eb 17                	jmp    801915 <open+0x86>
	}

	return fd2num(fd);
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	ff 75 f4             	pushl  -0xc(%ebp)
  801904:	e8 2c f8 ff ff       	call   801135 <fd2num>
  801909:	89 c2                	mov    %eax,%edx
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	eb 05                	jmp    801915 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801910:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801915:	89 d0                	mov    %edx,%eax
  801917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801922:	ba 00 00 00 00       	mov    $0x0,%edx
  801927:	b8 08 00 00 00       	mov    $0x8,%eax
  80192c:	e8 b3 fd ff ff       	call   8016e4 <fsipc>
}
  801931:	c9                   	leave  
  801932:	c3                   	ret    

00801933 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801939:	68 8f 2b 80 00       	push   $0x802b8f
  80193e:	ff 75 0c             	pushl  0xc(%ebp)
  801941:	e8 dc f1 ff ff       	call   800b22 <strcpy>
	return 0;
}
  801946:	b8 00 00 00 00       	mov    $0x0,%eax
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	53                   	push   %ebx
  801951:	83 ec 10             	sub    $0x10,%esp
  801954:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801957:	53                   	push   %ebx
  801958:	e8 56 0a 00 00       	call   8023b3 <pageref>
  80195d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801960:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801965:	83 f8 01             	cmp    $0x1,%eax
  801968:	75 10                	jne    80197a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80196a:	83 ec 0c             	sub    $0xc,%esp
  80196d:	ff 73 0c             	pushl  0xc(%ebx)
  801970:	e8 c0 02 00 00       	call   801c35 <nsipc_close>
  801975:	89 c2                	mov    %eax,%edx
  801977:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80197a:	89 d0                	mov    %edx,%eax
  80197c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801987:	6a 00                	push   $0x0
  801989:	ff 75 10             	pushl  0x10(%ebp)
  80198c:	ff 75 0c             	pushl  0xc(%ebp)
  80198f:	8b 45 08             	mov    0x8(%ebp),%eax
  801992:	ff 70 0c             	pushl  0xc(%eax)
  801995:	e8 78 03 00 00       	call   801d12 <nsipc_send>
}
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019a2:	6a 00                	push   $0x0
  8019a4:	ff 75 10             	pushl  0x10(%ebp)
  8019a7:	ff 75 0c             	pushl  0xc(%ebp)
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	ff 70 0c             	pushl  0xc(%eax)
  8019b0:	e8 f1 02 00 00       	call   801ca6 <nsipc_recv>
}
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019bd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019c0:	52                   	push   %edx
  8019c1:	50                   	push   %eax
  8019c2:	e8 e4 f7 ff ff       	call   8011ab <fd_lookup>
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 17                	js     8019e5 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d1:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  8019d7:	39 08                	cmp    %ecx,(%eax)
  8019d9:	75 05                	jne    8019e0 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019db:	8b 40 0c             	mov    0xc(%eax),%eax
  8019de:	eb 05                	jmp    8019e5 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 1c             	sub    $0x1c,%esp
  8019ef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f4:	50                   	push   %eax
  8019f5:	e8 62 f7 ff ff       	call   80115c <fd_alloc>
  8019fa:	89 c3                	mov    %eax,%ebx
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 1b                	js     801a1e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a03:	83 ec 04             	sub    $0x4,%esp
  801a06:	68 07 04 00 00       	push   $0x407
  801a0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0e:	6a 00                	push   $0x0
  801a10:	e8 10 f5 ff ff       	call   800f25 <sys_page_alloc>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	79 10                	jns    801a2e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	56                   	push   %esi
  801a22:	e8 0e 02 00 00       	call   801c35 <nsipc_close>
		return r;
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	89 d8                	mov    %ebx,%eax
  801a2c:	eb 24                	jmp    801a52 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a2e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a37:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a43:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	50                   	push   %eax
  801a4a:	e8 e6 f6 ff ff       	call   801135 <fd2num>
  801a4f:	83 c4 10             	add    $0x10,%esp
}
  801a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	e8 50 ff ff ff       	call   8019b7 <fd2sockid>
		return r;
  801a67:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 1f                	js     801a8c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a6d:	83 ec 04             	sub    $0x4,%esp
  801a70:	ff 75 10             	pushl  0x10(%ebp)
  801a73:	ff 75 0c             	pushl  0xc(%ebp)
  801a76:	50                   	push   %eax
  801a77:	e8 12 01 00 00       	call   801b8e <nsipc_accept>
  801a7c:	83 c4 10             	add    $0x10,%esp
		return r;
  801a7f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 07                	js     801a8c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a85:	e8 5d ff ff ff       	call   8019e7 <alloc_sockfd>
  801a8a:	89 c1                	mov    %eax,%ecx
}
  801a8c:	89 c8                	mov    %ecx,%eax
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	e8 19 ff ff ff       	call   8019b7 <fd2sockid>
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 12                	js     801ab4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	ff 75 10             	pushl  0x10(%ebp)
  801aa8:	ff 75 0c             	pushl  0xc(%ebp)
  801aab:	50                   	push   %eax
  801aac:	e8 2d 01 00 00       	call   801bde <nsipc_bind>
  801ab1:	83 c4 10             	add    $0x10,%esp
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <shutdown>:

int
shutdown(int s, int how)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	e8 f3 fe ff ff       	call   8019b7 <fd2sockid>
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	78 0f                	js     801ad7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ac8:	83 ec 08             	sub    $0x8,%esp
  801acb:	ff 75 0c             	pushl  0xc(%ebp)
  801ace:	50                   	push   %eax
  801acf:	e8 3f 01 00 00       	call   801c13 <nsipc_shutdown>
  801ad4:	83 c4 10             	add    $0x10,%esp
}
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae2:	e8 d0 fe ff ff       	call   8019b7 <fd2sockid>
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 12                	js     801afd <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801aeb:	83 ec 04             	sub    $0x4,%esp
  801aee:	ff 75 10             	pushl  0x10(%ebp)
  801af1:	ff 75 0c             	pushl  0xc(%ebp)
  801af4:	50                   	push   %eax
  801af5:	e8 55 01 00 00       	call   801c4f <nsipc_connect>
  801afa:	83 c4 10             	add    $0x10,%esp
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <listen>:

int
listen(int s, int backlog)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b05:	8b 45 08             	mov    0x8(%ebp),%eax
  801b08:	e8 aa fe ff ff       	call   8019b7 <fd2sockid>
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 0f                	js     801b20 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b11:	83 ec 08             	sub    $0x8,%esp
  801b14:	ff 75 0c             	pushl  0xc(%ebp)
  801b17:	50                   	push   %eax
  801b18:	e8 67 01 00 00       	call   801c84 <nsipc_listen>
  801b1d:	83 c4 10             	add    $0x10,%esp
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b28:	ff 75 10             	pushl  0x10(%ebp)
  801b2b:	ff 75 0c             	pushl  0xc(%ebp)
  801b2e:	ff 75 08             	pushl  0x8(%ebp)
  801b31:	e8 3a 02 00 00       	call   801d70 <nsipc_socket>
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 05                	js     801b42 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b3d:	e8 a5 fe ff ff       	call   8019e7 <alloc_sockfd>
}
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	53                   	push   %ebx
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b4d:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801b54:	75 12                	jne    801b68 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	6a 02                	push   $0x2
  801b5b:	e8 1a 08 00 00       	call   80237a <ipc_find_env>
  801b60:	a3 14 40 80 00       	mov    %eax,0x804014
  801b65:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b68:	6a 07                	push   $0x7
  801b6a:	68 00 60 80 00       	push   $0x806000
  801b6f:	53                   	push   %ebx
  801b70:	ff 35 14 40 80 00    	pushl  0x804014
  801b76:	e8 ab 07 00 00       	call   802326 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b7b:	83 c4 0c             	add    $0xc,%esp
  801b7e:	6a 00                	push   $0x0
  801b80:	6a 00                	push   $0x0
  801b82:	6a 00                	push   $0x0
  801b84:	e8 36 07 00 00       	call   8022bf <ipc_recv>
}
  801b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b9e:	8b 06                	mov    (%esi),%eax
  801ba0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ba5:	b8 01 00 00 00       	mov    $0x1,%eax
  801baa:	e8 95 ff ff ff       	call   801b44 <nsipc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 20                	js     801bd5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	ff 35 10 60 80 00    	pushl  0x806010
  801bbe:	68 00 60 80 00       	push   $0x806000
  801bc3:	ff 75 0c             	pushl  0xc(%ebp)
  801bc6:	e8 e9 f0 ff ff       	call   800cb4 <memmove>
		*addrlen = ret->ret_addrlen;
  801bcb:	a1 10 60 80 00       	mov    0x806010,%eax
  801bd0:	89 06                	mov    %eax,(%esi)
  801bd2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bd5:	89 d8                	mov    %ebx,%eax
  801bd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	53                   	push   %ebx
  801be2:	83 ec 08             	sub    $0x8,%esp
  801be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801be8:	8b 45 08             	mov    0x8(%ebp),%eax
  801beb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bf0:	53                   	push   %ebx
  801bf1:	ff 75 0c             	pushl  0xc(%ebp)
  801bf4:	68 04 60 80 00       	push   $0x806004
  801bf9:	e8 b6 f0 ff ff       	call   800cb4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bfe:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c04:	b8 02 00 00 00       	mov    $0x2,%eax
  801c09:	e8 36 ff ff ff       	call   801b44 <nsipc>
}
  801c0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c24:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c29:	b8 03 00 00 00       	mov    $0x3,%eax
  801c2e:	e8 11 ff ff ff       	call   801b44 <nsipc>
}
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <nsipc_close>:

int
nsipc_close(int s)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c43:	b8 04 00 00 00       	mov    $0x4,%eax
  801c48:	e8 f7 fe ff ff       	call   801b44 <nsipc>
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	53                   	push   %ebx
  801c53:	83 ec 08             	sub    $0x8,%esp
  801c56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c59:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c61:	53                   	push   %ebx
  801c62:	ff 75 0c             	pushl  0xc(%ebp)
  801c65:	68 04 60 80 00       	push   $0x806004
  801c6a:	e8 45 f0 ff ff       	call   800cb4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c6f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c75:	b8 05 00 00 00       	mov    $0x5,%eax
  801c7a:	e8 c5 fe ff ff       	call   801b44 <nsipc>
}
  801c7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c95:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c9a:	b8 06 00 00 00       	mov    $0x6,%eax
  801c9f:	e8 a0 fe ff ff       	call   801b44 <nsipc>
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	56                   	push   %esi
  801caa:	53                   	push   %ebx
  801cab:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cb6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cbc:	8b 45 14             	mov    0x14(%ebp),%eax
  801cbf:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cc4:	b8 07 00 00 00       	mov    $0x7,%eax
  801cc9:	e8 76 fe ff ff       	call   801b44 <nsipc>
  801cce:	89 c3                	mov    %eax,%ebx
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	78 35                	js     801d09 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cd4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cd9:	7f 04                	jg     801cdf <nsipc_recv+0x39>
  801cdb:	39 c6                	cmp    %eax,%esi
  801cdd:	7d 16                	jge    801cf5 <nsipc_recv+0x4f>
  801cdf:	68 9b 2b 80 00       	push   $0x802b9b
  801ce4:	68 63 2b 80 00       	push   $0x802b63
  801ce9:	6a 62                	push   $0x62
  801ceb:	68 b0 2b 80 00       	push   $0x802bb0
  801cf0:	e8 84 05 00 00       	call   802279 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cf5:	83 ec 04             	sub    $0x4,%esp
  801cf8:	50                   	push   %eax
  801cf9:	68 00 60 80 00       	push   $0x806000
  801cfe:	ff 75 0c             	pushl  0xc(%ebp)
  801d01:	e8 ae ef ff ff       	call   800cb4 <memmove>
  801d06:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d09:	89 d8                	mov    %ebx,%eax
  801d0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	53                   	push   %ebx
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d24:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d2a:	7e 16                	jle    801d42 <nsipc_send+0x30>
  801d2c:	68 bc 2b 80 00       	push   $0x802bbc
  801d31:	68 63 2b 80 00       	push   $0x802b63
  801d36:	6a 6d                	push   $0x6d
  801d38:	68 b0 2b 80 00       	push   $0x802bb0
  801d3d:	e8 37 05 00 00       	call   802279 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d42:	83 ec 04             	sub    $0x4,%esp
  801d45:	53                   	push   %ebx
  801d46:	ff 75 0c             	pushl  0xc(%ebp)
  801d49:	68 0c 60 80 00       	push   $0x80600c
  801d4e:	e8 61 ef ff ff       	call   800cb4 <memmove>
	nsipcbuf.send.req_size = size;
  801d53:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d59:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d61:	b8 08 00 00 00       	mov    $0x8,%eax
  801d66:	e8 d9 fd ff ff       	call   801b44 <nsipc>
}
  801d6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d6e:	c9                   	leave  
  801d6f:	c3                   	ret    

00801d70 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d81:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d86:	8b 45 10             	mov    0x10(%ebp),%eax
  801d89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d8e:	b8 09 00 00 00       	mov    $0x9,%eax
  801d93:	e8 ac fd ff ff       	call   801b44 <nsipc>
}
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	56                   	push   %esi
  801d9e:	53                   	push   %ebx
  801d9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff 75 08             	pushl  0x8(%ebp)
  801da8:	e8 98 f3 ff ff       	call   801145 <fd2data>
  801dad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801daf:	83 c4 08             	add    $0x8,%esp
  801db2:	68 c8 2b 80 00       	push   $0x802bc8
  801db7:	53                   	push   %ebx
  801db8:	e8 65 ed ff ff       	call   800b22 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dbd:	8b 46 04             	mov    0x4(%esi),%eax
  801dc0:	2b 06                	sub    (%esi),%eax
  801dc2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dc8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dcf:	00 00 00 
	stat->st_dev = &devpipe;
  801dd2:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801dd9:	30 80 00 
	return 0;
}
  801ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  801de1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	53                   	push   %ebx
  801dec:	83 ec 0c             	sub    $0xc,%esp
  801def:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801df2:	53                   	push   %ebx
  801df3:	6a 00                	push   $0x0
  801df5:	e8 b0 f1 ff ff       	call   800faa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dfa:	89 1c 24             	mov    %ebx,(%esp)
  801dfd:	e8 43 f3 ff ff       	call   801145 <fd2data>
  801e02:	83 c4 08             	add    $0x8,%esp
  801e05:	50                   	push   %eax
  801e06:	6a 00                	push   $0x0
  801e08:	e8 9d f1 ff ff       	call   800faa <sys_page_unmap>
}
  801e0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	83 ec 1c             	sub    $0x1c,%esp
  801e1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e1e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e20:	a1 18 40 80 00       	mov    0x804018,%eax
  801e25:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	ff 75 e0             	pushl  -0x20(%ebp)
  801e2e:	e8 80 05 00 00       	call   8023b3 <pageref>
  801e33:	89 c3                	mov    %eax,%ebx
  801e35:	89 3c 24             	mov    %edi,(%esp)
  801e38:	e8 76 05 00 00       	call   8023b3 <pageref>
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	39 c3                	cmp    %eax,%ebx
  801e42:	0f 94 c1             	sete   %cl
  801e45:	0f b6 c9             	movzbl %cl,%ecx
  801e48:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e4b:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801e51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e54:	39 ce                	cmp    %ecx,%esi
  801e56:	74 1b                	je     801e73 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e58:	39 c3                	cmp    %eax,%ebx
  801e5a:	75 c4                	jne    801e20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e5c:	8b 42 58             	mov    0x58(%edx),%eax
  801e5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e62:	50                   	push   %eax
  801e63:	56                   	push   %esi
  801e64:	68 cf 2b 80 00       	push   $0x802bcf
  801e69:	e8 2f e7 ff ff       	call   80059d <cprintf>
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	eb ad                	jmp    801e20 <_pipeisclosed+0xe>
	}
}
  801e73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e79:	5b                   	pop    %ebx
  801e7a:	5e                   	pop    %esi
  801e7b:	5f                   	pop    %edi
  801e7c:	5d                   	pop    %ebp
  801e7d:	c3                   	ret    

00801e7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	83 ec 28             	sub    $0x28,%esp
  801e87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e8a:	56                   	push   %esi
  801e8b:	e8 b5 f2 ff ff       	call   801145 <fd2data>
  801e90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	bf 00 00 00 00       	mov    $0x0,%edi
  801e9a:	eb 4b                	jmp    801ee7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e9c:	89 da                	mov    %ebx,%edx
  801e9e:	89 f0                	mov    %esi,%eax
  801ea0:	e8 6d ff ff ff       	call   801e12 <_pipeisclosed>
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	75 48                	jne    801ef1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ea9:	e8 58 f0 ff ff       	call   800f06 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eae:	8b 43 04             	mov    0x4(%ebx),%eax
  801eb1:	8b 0b                	mov    (%ebx),%ecx
  801eb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801eb6:	39 d0                	cmp    %edx,%eax
  801eb8:	73 e2                	jae    801e9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801eba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ebd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ec1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ec4:	89 c2                	mov    %eax,%edx
  801ec6:	c1 fa 1f             	sar    $0x1f,%edx
  801ec9:	89 d1                	mov    %edx,%ecx
  801ecb:	c1 e9 1b             	shr    $0x1b,%ecx
  801ece:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ed1:	83 e2 1f             	and    $0x1f,%edx
  801ed4:	29 ca                	sub    %ecx,%edx
  801ed6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801eda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ede:	83 c0 01             	add    $0x1,%eax
  801ee1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee4:	83 c7 01             	add    $0x1,%edi
  801ee7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eea:	75 c2                	jne    801eae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801eec:	8b 45 10             	mov    0x10(%ebp),%eax
  801eef:	eb 05                	jmp    801ef6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef9:	5b                   	pop    %ebx
  801efa:	5e                   	pop    %esi
  801efb:	5f                   	pop    %edi
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 18             	sub    $0x18,%esp
  801f07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f0a:	57                   	push   %edi
  801f0b:	e8 35 f2 ff ff       	call   801145 <fd2data>
  801f10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f1a:	eb 3d                	jmp    801f59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f1c:	85 db                	test   %ebx,%ebx
  801f1e:	74 04                	je     801f24 <devpipe_read+0x26>
				return i;
  801f20:	89 d8                	mov    %ebx,%eax
  801f22:	eb 44                	jmp    801f68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f24:	89 f2                	mov    %esi,%edx
  801f26:	89 f8                	mov    %edi,%eax
  801f28:	e8 e5 fe ff ff       	call   801e12 <_pipeisclosed>
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	75 32                	jne    801f63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f31:	e8 d0 ef ff ff       	call   800f06 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f36:	8b 06                	mov    (%esi),%eax
  801f38:	3b 46 04             	cmp    0x4(%esi),%eax
  801f3b:	74 df                	je     801f1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f3d:	99                   	cltd   
  801f3e:	c1 ea 1b             	shr    $0x1b,%edx
  801f41:	01 d0                	add    %edx,%eax
  801f43:	83 e0 1f             	and    $0x1f,%eax
  801f46:	29 d0                	sub    %edx,%eax
  801f48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f56:	83 c3 01             	add    $0x1,%ebx
  801f59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f5c:	75 d8                	jne    801f36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801f61:	eb 05                	jmp    801f68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6b:	5b                   	pop    %ebx
  801f6c:	5e                   	pop    %esi
  801f6d:	5f                   	pop    %edi
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	56                   	push   %esi
  801f74:	53                   	push   %ebx
  801f75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7b:	50                   	push   %eax
  801f7c:	e8 db f1 ff ff       	call   80115c <fd_alloc>
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	89 c2                	mov    %eax,%edx
  801f86:	85 c0                	test   %eax,%eax
  801f88:	0f 88 2c 01 00 00    	js     8020ba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f8e:	83 ec 04             	sub    $0x4,%esp
  801f91:	68 07 04 00 00       	push   $0x407
  801f96:	ff 75 f4             	pushl  -0xc(%ebp)
  801f99:	6a 00                	push   $0x0
  801f9b:	e8 85 ef ff ff       	call   800f25 <sys_page_alloc>
  801fa0:	83 c4 10             	add    $0x10,%esp
  801fa3:	89 c2                	mov    %eax,%edx
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	0f 88 0d 01 00 00    	js     8020ba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fad:	83 ec 0c             	sub    $0xc,%esp
  801fb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fb3:	50                   	push   %eax
  801fb4:	e8 a3 f1 ff ff       	call   80115c <fd_alloc>
  801fb9:	89 c3                	mov    %eax,%ebx
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	0f 88 e2 00 00 00    	js     8020a8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc6:	83 ec 04             	sub    $0x4,%esp
  801fc9:	68 07 04 00 00       	push   $0x407
  801fce:	ff 75 f0             	pushl  -0x10(%ebp)
  801fd1:	6a 00                	push   $0x0
  801fd3:	e8 4d ef ff ff       	call   800f25 <sys_page_alloc>
  801fd8:	89 c3                	mov    %eax,%ebx
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	0f 88 c3 00 00 00    	js     8020a8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fe5:	83 ec 0c             	sub    $0xc,%esp
  801fe8:	ff 75 f4             	pushl  -0xc(%ebp)
  801feb:	e8 55 f1 ff ff       	call   801145 <fd2data>
  801ff0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff2:	83 c4 0c             	add    $0xc,%esp
  801ff5:	68 07 04 00 00       	push   $0x407
  801ffa:	50                   	push   %eax
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 23 ef ff ff       	call   800f25 <sys_page_alloc>
  802002:	89 c3                	mov    %eax,%ebx
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	0f 88 89 00 00 00    	js     802098 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200f:	83 ec 0c             	sub    $0xc,%esp
  802012:	ff 75 f0             	pushl  -0x10(%ebp)
  802015:	e8 2b f1 ff ff       	call   801145 <fd2data>
  80201a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802021:	50                   	push   %eax
  802022:	6a 00                	push   $0x0
  802024:	56                   	push   %esi
  802025:	6a 00                	push   $0x0
  802027:	e8 3c ef ff ff       	call   800f68 <sys_page_map>
  80202c:	89 c3                	mov    %eax,%ebx
  80202e:	83 c4 20             	add    $0x20,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	78 55                	js     80208a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802035:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80203b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802043:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80204a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802050:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802053:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802055:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802058:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80205f:	83 ec 0c             	sub    $0xc,%esp
  802062:	ff 75 f4             	pushl  -0xc(%ebp)
  802065:	e8 cb f0 ff ff       	call   801135 <fd2num>
  80206a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80206d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80206f:	83 c4 04             	add    $0x4,%esp
  802072:	ff 75 f0             	pushl  -0x10(%ebp)
  802075:	e8 bb f0 ff ff       	call   801135 <fd2num>
  80207a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80207d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	ba 00 00 00 00       	mov    $0x0,%edx
  802088:	eb 30                	jmp    8020ba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80208a:	83 ec 08             	sub    $0x8,%esp
  80208d:	56                   	push   %esi
  80208e:	6a 00                	push   $0x0
  802090:	e8 15 ef ff ff       	call   800faa <sys_page_unmap>
  802095:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802098:	83 ec 08             	sub    $0x8,%esp
  80209b:	ff 75 f0             	pushl  -0x10(%ebp)
  80209e:	6a 00                	push   $0x0
  8020a0:	e8 05 ef ff ff       	call   800faa <sys_page_unmap>
  8020a5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020a8:	83 ec 08             	sub    $0x8,%esp
  8020ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ae:	6a 00                	push   $0x0
  8020b0:	e8 f5 ee ff ff       	call   800faa <sys_page_unmap>
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    

008020c3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cc:	50                   	push   %eax
  8020cd:	ff 75 08             	pushl  0x8(%ebp)
  8020d0:	e8 d6 f0 ff ff       	call   8011ab <fd_lookup>
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	78 18                	js     8020f4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020dc:	83 ec 0c             	sub    $0xc,%esp
  8020df:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e2:	e8 5e f0 ff ff       	call   801145 <fd2data>
	return _pipeisclosed(fd, p);
  8020e7:	89 c2                	mov    %eax,%edx
  8020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ec:	e8 21 fd ff ff       	call   801e12 <_pipeisclosed>
  8020f1:	83 c4 10             	add    $0x10,%esp
}
  8020f4:	c9                   	leave  
  8020f5:	c3                   	ret    

008020f6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    

00802100 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802106:	68 e7 2b 80 00       	push   $0x802be7
  80210b:	ff 75 0c             	pushl  0xc(%ebp)
  80210e:	e8 0f ea ff ff       	call   800b22 <strcpy>
	return 0;
}
  802113:	b8 00 00 00 00       	mov    $0x0,%eax
  802118:	c9                   	leave  
  802119:	c3                   	ret    

0080211a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	57                   	push   %edi
  80211e:	56                   	push   %esi
  80211f:	53                   	push   %ebx
  802120:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802126:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80212b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802131:	eb 2d                	jmp    802160 <devcons_write+0x46>
		m = n - tot;
  802133:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802136:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802138:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80213b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802140:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802143:	83 ec 04             	sub    $0x4,%esp
  802146:	53                   	push   %ebx
  802147:	03 45 0c             	add    0xc(%ebp),%eax
  80214a:	50                   	push   %eax
  80214b:	57                   	push   %edi
  80214c:	e8 63 eb ff ff       	call   800cb4 <memmove>
		sys_cputs(buf, m);
  802151:	83 c4 08             	add    $0x8,%esp
  802154:	53                   	push   %ebx
  802155:	57                   	push   %edi
  802156:	e8 0e ed ff ff       	call   800e69 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80215b:	01 de                	add    %ebx,%esi
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	89 f0                	mov    %esi,%eax
  802162:	3b 75 10             	cmp    0x10(%ebp),%esi
  802165:	72 cc                	jb     802133 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	5f                   	pop    %edi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    

0080216f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80216f:	55                   	push   %ebp
  802170:	89 e5                	mov    %esp,%ebp
  802172:	83 ec 08             	sub    $0x8,%esp
  802175:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80217a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80217e:	74 2a                	je     8021aa <devcons_read+0x3b>
  802180:	eb 05                	jmp    802187 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802182:	e8 7f ed ff ff       	call   800f06 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802187:	e8 fb ec ff ff       	call   800e87 <sys_cgetc>
  80218c:	85 c0                	test   %eax,%eax
  80218e:	74 f2                	je     802182 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802190:	85 c0                	test   %eax,%eax
  802192:	78 16                	js     8021aa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802194:	83 f8 04             	cmp    $0x4,%eax
  802197:	74 0c                	je     8021a5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80219c:	88 02                	mov    %al,(%edx)
	return 1;
  80219e:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a3:	eb 05                	jmp    8021aa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021a5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021aa:	c9                   	leave  
  8021ab:	c3                   	ret    

008021ac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021b8:	6a 01                	push   $0x1
  8021ba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021bd:	50                   	push   %eax
  8021be:	e8 a6 ec ff ff       	call   800e69 <sys_cputs>
}
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    

008021c8 <getchar>:

int
getchar(void)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021ce:	6a 01                	push   $0x1
  8021d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d3:	50                   	push   %eax
  8021d4:	6a 00                	push   $0x0
  8021d6:	e8 36 f2 ff ff       	call   801411 <read>
	if (r < 0)
  8021db:	83 c4 10             	add    $0x10,%esp
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 0f                	js     8021f1 <getchar+0x29>
		return r;
	if (r < 1)
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	7e 06                	jle    8021ec <getchar+0x24>
		return -E_EOF;
	return c;
  8021e6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021ea:	eb 05                	jmp    8021f1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021ec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fc:	50                   	push   %eax
  8021fd:	ff 75 08             	pushl  0x8(%ebp)
  802200:	e8 a6 ef ff ff       	call   8011ab <fd_lookup>
  802205:	83 c4 10             	add    $0x10,%esp
  802208:	85 c0                	test   %eax,%eax
  80220a:	78 11                	js     80221d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80220c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220f:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802215:	39 10                	cmp    %edx,(%eax)
  802217:	0f 94 c0             	sete   %al
  80221a:	0f b6 c0             	movzbl %al,%eax
}
  80221d:	c9                   	leave  
  80221e:	c3                   	ret    

0080221f <opencons>:

int
opencons(void)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802225:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802228:	50                   	push   %eax
  802229:	e8 2e ef ff ff       	call   80115c <fd_alloc>
  80222e:	83 c4 10             	add    $0x10,%esp
		return r;
  802231:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802233:	85 c0                	test   %eax,%eax
  802235:	78 3e                	js     802275 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802237:	83 ec 04             	sub    $0x4,%esp
  80223a:	68 07 04 00 00       	push   $0x407
  80223f:	ff 75 f4             	pushl  -0xc(%ebp)
  802242:	6a 00                	push   $0x0
  802244:	e8 dc ec ff ff       	call   800f25 <sys_page_alloc>
  802249:	83 c4 10             	add    $0x10,%esp
		return r;
  80224c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80224e:	85 c0                	test   %eax,%eax
  802250:	78 23                	js     802275 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802252:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80225d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802260:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802267:	83 ec 0c             	sub    $0xc,%esp
  80226a:	50                   	push   %eax
  80226b:	e8 c5 ee ff ff       	call   801135 <fd2num>
  802270:	89 c2                	mov    %eax,%edx
  802272:	83 c4 10             	add    $0x10,%esp
}
  802275:	89 d0                	mov    %edx,%eax
  802277:	c9                   	leave  
  802278:	c3                   	ret    

00802279 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	56                   	push   %esi
  80227d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80227e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802281:	8b 35 04 30 80 00    	mov    0x803004,%esi
  802287:	e8 5b ec ff ff       	call   800ee7 <sys_getenvid>
  80228c:	83 ec 0c             	sub    $0xc,%esp
  80228f:	ff 75 0c             	pushl  0xc(%ebp)
  802292:	ff 75 08             	pushl  0x8(%ebp)
  802295:	56                   	push   %esi
  802296:	50                   	push   %eax
  802297:	68 f4 2b 80 00       	push   $0x802bf4
  80229c:	e8 fc e2 ff ff       	call   80059d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022a1:	83 c4 18             	add    $0x18,%esp
  8022a4:	53                   	push   %ebx
  8022a5:	ff 75 10             	pushl  0x10(%ebp)
  8022a8:	e8 9f e2 ff ff       	call   80054c <vcprintf>
	cprintf("\n");
  8022ad:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  8022b4:	e8 e4 e2 ff ff       	call   80059d <cprintf>
  8022b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022bc:	cc                   	int3   
  8022bd:	eb fd                	jmp    8022bc <_panic+0x43>

008022bf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8022c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8022cd:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8022cf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022d4:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8022d7:	83 ec 0c             	sub    $0xc,%esp
  8022da:	50                   	push   %eax
  8022db:	e8 f5 ed ff ff       	call   8010d5 <sys_ipc_recv>

	if (from_env_store != NULL)
  8022e0:	83 c4 10             	add    $0x10,%esp
  8022e3:	85 f6                	test   %esi,%esi
  8022e5:	74 14                	je     8022fb <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8022e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	78 09                	js     8022f9 <ipc_recv+0x3a>
  8022f0:	8b 15 18 40 80 00    	mov    0x804018,%edx
  8022f6:	8b 52 74             	mov    0x74(%edx),%edx
  8022f9:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8022fb:	85 db                	test   %ebx,%ebx
  8022fd:	74 14                	je     802313 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8022ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802304:	85 c0                	test   %eax,%eax
  802306:	78 09                	js     802311 <ipc_recv+0x52>
  802308:	8b 15 18 40 80 00    	mov    0x804018,%edx
  80230e:	8b 52 78             	mov    0x78(%edx),%edx
  802311:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802313:	85 c0                	test   %eax,%eax
  802315:	78 08                	js     80231f <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802317:	a1 18 40 80 00       	mov    0x804018,%eax
  80231c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80231f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802322:	5b                   	pop    %ebx
  802323:	5e                   	pop    %esi
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    

00802326 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802326:	55                   	push   %ebp
  802327:	89 e5                	mov    %esp,%ebp
  802329:	57                   	push   %edi
  80232a:	56                   	push   %esi
  80232b:	53                   	push   %ebx
  80232c:	83 ec 0c             	sub    $0xc,%esp
  80232f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802332:	8b 75 0c             	mov    0xc(%ebp),%esi
  802335:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802338:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80233a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80233f:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802342:	ff 75 14             	pushl  0x14(%ebp)
  802345:	53                   	push   %ebx
  802346:	56                   	push   %esi
  802347:	57                   	push   %edi
  802348:	e8 65 ed ff ff       	call   8010b2 <sys_ipc_try_send>

		if (err < 0) {
  80234d:	83 c4 10             	add    $0x10,%esp
  802350:	85 c0                	test   %eax,%eax
  802352:	79 1e                	jns    802372 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802354:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802357:	75 07                	jne    802360 <ipc_send+0x3a>
				sys_yield();
  802359:	e8 a8 eb ff ff       	call   800f06 <sys_yield>
  80235e:	eb e2                	jmp    802342 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802360:	50                   	push   %eax
  802361:	68 18 2c 80 00       	push   $0x802c18
  802366:	6a 49                	push   $0x49
  802368:	68 25 2c 80 00       	push   $0x802c25
  80236d:	e8 07 ff ff ff       	call   802279 <_panic>
		}

	} while (err < 0);

}
  802372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802375:	5b                   	pop    %ebx
  802376:	5e                   	pop    %esi
  802377:	5f                   	pop    %edi
  802378:	5d                   	pop    %ebp
  802379:	c3                   	ret    

0080237a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802380:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802385:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802388:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80238e:	8b 52 50             	mov    0x50(%edx),%edx
  802391:	39 ca                	cmp    %ecx,%edx
  802393:	75 0d                	jne    8023a2 <ipc_find_env+0x28>
			return envs[i].env_id;
  802395:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802398:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80239d:	8b 40 48             	mov    0x48(%eax),%eax
  8023a0:	eb 0f                	jmp    8023b1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023a2:	83 c0 01             	add    $0x1,%eax
  8023a5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023aa:	75 d9                	jne    802385 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    

008023b3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023b3:	55                   	push   %ebp
  8023b4:	89 e5                	mov    %esp,%ebp
  8023b6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b9:	89 d0                	mov    %edx,%eax
  8023bb:	c1 e8 16             	shr    $0x16,%eax
  8023be:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023c5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023ca:	f6 c1 01             	test   $0x1,%cl
  8023cd:	74 1d                	je     8023ec <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023cf:	c1 ea 0c             	shr    $0xc,%edx
  8023d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023d9:	f6 c2 01             	test   $0x1,%dl
  8023dc:	74 0e                	je     8023ec <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023de:	c1 ea 0c             	shr    $0xc,%edx
  8023e1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023e8:	ef 
  8023e9:	0f b7 c0             	movzwl %ax,%eax
}
  8023ec:	5d                   	pop    %ebp
  8023ed:	c3                   	ret    
  8023ee:	66 90                	xchg   %ax,%ax

008023f0 <__udivdi3>:
  8023f0:	55                   	push   %ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	53                   	push   %ebx
  8023f4:	83 ec 1c             	sub    $0x1c,%esp
  8023f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802403:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802407:	85 f6                	test   %esi,%esi
  802409:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80240d:	89 ca                	mov    %ecx,%edx
  80240f:	89 f8                	mov    %edi,%eax
  802411:	75 3d                	jne    802450 <__udivdi3+0x60>
  802413:	39 cf                	cmp    %ecx,%edi
  802415:	0f 87 c5 00 00 00    	ja     8024e0 <__udivdi3+0xf0>
  80241b:	85 ff                	test   %edi,%edi
  80241d:	89 fd                	mov    %edi,%ebp
  80241f:	75 0b                	jne    80242c <__udivdi3+0x3c>
  802421:	b8 01 00 00 00       	mov    $0x1,%eax
  802426:	31 d2                	xor    %edx,%edx
  802428:	f7 f7                	div    %edi
  80242a:	89 c5                	mov    %eax,%ebp
  80242c:	89 c8                	mov    %ecx,%eax
  80242e:	31 d2                	xor    %edx,%edx
  802430:	f7 f5                	div    %ebp
  802432:	89 c1                	mov    %eax,%ecx
  802434:	89 d8                	mov    %ebx,%eax
  802436:	89 cf                	mov    %ecx,%edi
  802438:	f7 f5                	div    %ebp
  80243a:	89 c3                	mov    %eax,%ebx
  80243c:	89 d8                	mov    %ebx,%eax
  80243e:	89 fa                	mov    %edi,%edx
  802440:	83 c4 1c             	add    $0x1c,%esp
  802443:	5b                   	pop    %ebx
  802444:	5e                   	pop    %esi
  802445:	5f                   	pop    %edi
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	90                   	nop
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	39 ce                	cmp    %ecx,%esi
  802452:	77 74                	ja     8024c8 <__udivdi3+0xd8>
  802454:	0f bd fe             	bsr    %esi,%edi
  802457:	83 f7 1f             	xor    $0x1f,%edi
  80245a:	0f 84 98 00 00 00    	je     8024f8 <__udivdi3+0x108>
  802460:	bb 20 00 00 00       	mov    $0x20,%ebx
  802465:	89 f9                	mov    %edi,%ecx
  802467:	89 c5                	mov    %eax,%ebp
  802469:	29 fb                	sub    %edi,%ebx
  80246b:	d3 e6                	shl    %cl,%esi
  80246d:	89 d9                	mov    %ebx,%ecx
  80246f:	d3 ed                	shr    %cl,%ebp
  802471:	89 f9                	mov    %edi,%ecx
  802473:	d3 e0                	shl    %cl,%eax
  802475:	09 ee                	or     %ebp,%esi
  802477:	89 d9                	mov    %ebx,%ecx
  802479:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80247d:	89 d5                	mov    %edx,%ebp
  80247f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802483:	d3 ed                	shr    %cl,%ebp
  802485:	89 f9                	mov    %edi,%ecx
  802487:	d3 e2                	shl    %cl,%edx
  802489:	89 d9                	mov    %ebx,%ecx
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	09 c2                	or     %eax,%edx
  80248f:	89 d0                	mov    %edx,%eax
  802491:	89 ea                	mov    %ebp,%edx
  802493:	f7 f6                	div    %esi
  802495:	89 d5                	mov    %edx,%ebp
  802497:	89 c3                	mov    %eax,%ebx
  802499:	f7 64 24 0c          	mull   0xc(%esp)
  80249d:	39 d5                	cmp    %edx,%ebp
  80249f:	72 10                	jb     8024b1 <__udivdi3+0xc1>
  8024a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	d3 e6                	shl    %cl,%esi
  8024a9:	39 c6                	cmp    %eax,%esi
  8024ab:	73 07                	jae    8024b4 <__udivdi3+0xc4>
  8024ad:	39 d5                	cmp    %edx,%ebp
  8024af:	75 03                	jne    8024b4 <__udivdi3+0xc4>
  8024b1:	83 eb 01             	sub    $0x1,%ebx
  8024b4:	31 ff                	xor    %edi,%edi
  8024b6:	89 d8                	mov    %ebx,%eax
  8024b8:	89 fa                	mov    %edi,%edx
  8024ba:	83 c4 1c             	add    $0x1c,%esp
  8024bd:	5b                   	pop    %ebx
  8024be:	5e                   	pop    %esi
  8024bf:	5f                   	pop    %edi
  8024c0:	5d                   	pop    %ebp
  8024c1:	c3                   	ret    
  8024c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024c8:	31 ff                	xor    %edi,%edi
  8024ca:	31 db                	xor    %ebx,%ebx
  8024cc:	89 d8                	mov    %ebx,%eax
  8024ce:	89 fa                	mov    %edi,%edx
  8024d0:	83 c4 1c             	add    $0x1c,%esp
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    
  8024d8:	90                   	nop
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	89 d8                	mov    %ebx,%eax
  8024e2:	f7 f7                	div    %edi
  8024e4:	31 ff                	xor    %edi,%edi
  8024e6:	89 c3                	mov    %eax,%ebx
  8024e8:	89 d8                	mov    %ebx,%eax
  8024ea:	89 fa                	mov    %edi,%edx
  8024ec:	83 c4 1c             	add    $0x1c,%esp
  8024ef:	5b                   	pop    %ebx
  8024f0:	5e                   	pop    %esi
  8024f1:	5f                   	pop    %edi
  8024f2:	5d                   	pop    %ebp
  8024f3:	c3                   	ret    
  8024f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	39 ce                	cmp    %ecx,%esi
  8024fa:	72 0c                	jb     802508 <__udivdi3+0x118>
  8024fc:	31 db                	xor    %ebx,%ebx
  8024fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802502:	0f 87 34 ff ff ff    	ja     80243c <__udivdi3+0x4c>
  802508:	bb 01 00 00 00       	mov    $0x1,%ebx
  80250d:	e9 2a ff ff ff       	jmp    80243c <__udivdi3+0x4c>
  802512:	66 90                	xchg   %ax,%ax
  802514:	66 90                	xchg   %ax,%ax
  802516:	66 90                	xchg   %ax,%ax
  802518:	66 90                	xchg   %ax,%ax
  80251a:	66 90                	xchg   %ax,%ax
  80251c:	66 90                	xchg   %ax,%ax
  80251e:	66 90                	xchg   %ax,%ax

00802520 <__umoddi3>:
  802520:	55                   	push   %ebp
  802521:	57                   	push   %edi
  802522:	56                   	push   %esi
  802523:	53                   	push   %ebx
  802524:	83 ec 1c             	sub    $0x1c,%esp
  802527:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80252b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80252f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802533:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802537:	85 d2                	test   %edx,%edx
  802539:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80253d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802541:	89 f3                	mov    %esi,%ebx
  802543:	89 3c 24             	mov    %edi,(%esp)
  802546:	89 74 24 04          	mov    %esi,0x4(%esp)
  80254a:	75 1c                	jne    802568 <__umoddi3+0x48>
  80254c:	39 f7                	cmp    %esi,%edi
  80254e:	76 50                	jbe    8025a0 <__umoddi3+0x80>
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	f7 f7                	div    %edi
  802556:	89 d0                	mov    %edx,%eax
  802558:	31 d2                	xor    %edx,%edx
  80255a:	83 c4 1c             	add    $0x1c,%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5f                   	pop    %edi
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    
  802562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802568:	39 f2                	cmp    %esi,%edx
  80256a:	89 d0                	mov    %edx,%eax
  80256c:	77 52                	ja     8025c0 <__umoddi3+0xa0>
  80256e:	0f bd ea             	bsr    %edx,%ebp
  802571:	83 f5 1f             	xor    $0x1f,%ebp
  802574:	75 5a                	jne    8025d0 <__umoddi3+0xb0>
  802576:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80257a:	0f 82 e0 00 00 00    	jb     802660 <__umoddi3+0x140>
  802580:	39 0c 24             	cmp    %ecx,(%esp)
  802583:	0f 86 d7 00 00 00    	jbe    802660 <__umoddi3+0x140>
  802589:	8b 44 24 08          	mov    0x8(%esp),%eax
  80258d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802591:	83 c4 1c             	add    $0x1c,%esp
  802594:	5b                   	pop    %ebx
  802595:	5e                   	pop    %esi
  802596:	5f                   	pop    %edi
  802597:	5d                   	pop    %ebp
  802598:	c3                   	ret    
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	85 ff                	test   %edi,%edi
  8025a2:	89 fd                	mov    %edi,%ebp
  8025a4:	75 0b                	jne    8025b1 <__umoddi3+0x91>
  8025a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ab:	31 d2                	xor    %edx,%edx
  8025ad:	f7 f7                	div    %edi
  8025af:	89 c5                	mov    %eax,%ebp
  8025b1:	89 f0                	mov    %esi,%eax
  8025b3:	31 d2                	xor    %edx,%edx
  8025b5:	f7 f5                	div    %ebp
  8025b7:	89 c8                	mov    %ecx,%eax
  8025b9:	f7 f5                	div    %ebp
  8025bb:	89 d0                	mov    %edx,%eax
  8025bd:	eb 99                	jmp    802558 <__umoddi3+0x38>
  8025bf:	90                   	nop
  8025c0:	89 c8                	mov    %ecx,%eax
  8025c2:	89 f2                	mov    %esi,%edx
  8025c4:	83 c4 1c             	add    $0x1c,%esp
  8025c7:	5b                   	pop    %ebx
  8025c8:	5e                   	pop    %esi
  8025c9:	5f                   	pop    %edi
  8025ca:	5d                   	pop    %ebp
  8025cb:	c3                   	ret    
  8025cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	8b 34 24             	mov    (%esp),%esi
  8025d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025d8:	89 e9                	mov    %ebp,%ecx
  8025da:	29 ef                	sub    %ebp,%edi
  8025dc:	d3 e0                	shl    %cl,%eax
  8025de:	89 f9                	mov    %edi,%ecx
  8025e0:	89 f2                	mov    %esi,%edx
  8025e2:	d3 ea                	shr    %cl,%edx
  8025e4:	89 e9                	mov    %ebp,%ecx
  8025e6:	09 c2                	or     %eax,%edx
  8025e8:	89 d8                	mov    %ebx,%eax
  8025ea:	89 14 24             	mov    %edx,(%esp)
  8025ed:	89 f2                	mov    %esi,%edx
  8025ef:	d3 e2                	shl    %cl,%edx
  8025f1:	89 f9                	mov    %edi,%ecx
  8025f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025fb:	d3 e8                	shr    %cl,%eax
  8025fd:	89 e9                	mov    %ebp,%ecx
  8025ff:	89 c6                	mov    %eax,%esi
  802601:	d3 e3                	shl    %cl,%ebx
  802603:	89 f9                	mov    %edi,%ecx
  802605:	89 d0                	mov    %edx,%eax
  802607:	d3 e8                	shr    %cl,%eax
  802609:	89 e9                	mov    %ebp,%ecx
  80260b:	09 d8                	or     %ebx,%eax
  80260d:	89 d3                	mov    %edx,%ebx
  80260f:	89 f2                	mov    %esi,%edx
  802611:	f7 34 24             	divl   (%esp)
  802614:	89 d6                	mov    %edx,%esi
  802616:	d3 e3                	shl    %cl,%ebx
  802618:	f7 64 24 04          	mull   0x4(%esp)
  80261c:	39 d6                	cmp    %edx,%esi
  80261e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802622:	89 d1                	mov    %edx,%ecx
  802624:	89 c3                	mov    %eax,%ebx
  802626:	72 08                	jb     802630 <__umoddi3+0x110>
  802628:	75 11                	jne    80263b <__umoddi3+0x11b>
  80262a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80262e:	73 0b                	jae    80263b <__umoddi3+0x11b>
  802630:	2b 44 24 04          	sub    0x4(%esp),%eax
  802634:	1b 14 24             	sbb    (%esp),%edx
  802637:	89 d1                	mov    %edx,%ecx
  802639:	89 c3                	mov    %eax,%ebx
  80263b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80263f:	29 da                	sub    %ebx,%edx
  802641:	19 ce                	sbb    %ecx,%esi
  802643:	89 f9                	mov    %edi,%ecx
  802645:	89 f0                	mov    %esi,%eax
  802647:	d3 e0                	shl    %cl,%eax
  802649:	89 e9                	mov    %ebp,%ecx
  80264b:	d3 ea                	shr    %cl,%edx
  80264d:	89 e9                	mov    %ebp,%ecx
  80264f:	d3 ee                	shr    %cl,%esi
  802651:	09 d0                	or     %edx,%eax
  802653:	89 f2                	mov    %esi,%edx
  802655:	83 c4 1c             	add    $0x1c,%esp
  802658:	5b                   	pop    %ebx
  802659:	5e                   	pop    %esi
  80265a:	5f                   	pop    %edi
  80265b:	5d                   	pop    %ebp
  80265c:	c3                   	ret    
  80265d:	8d 76 00             	lea    0x0(%esi),%esi
  802660:	29 f9                	sub    %edi,%ecx
  802662:	19 d6                	sbb    %edx,%esi
  802664:	89 74 24 04          	mov    %esi,0x4(%esp)
  802668:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80266c:	e9 18 ff ff ff       	jmp    802589 <__umoddi3+0x69>
